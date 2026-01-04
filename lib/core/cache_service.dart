import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kronium/core/logger_service.dart' as logging;
import 'package:kronium/core/error_handler.dart';
import 'package:kronium/core/config_service.dart';

/// Production-ready cache service with TTL and memory management
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  SharedPreferences? _prefs;
  final Map<String, _CacheItem> _memoryCache = {};
  Timer? _cleanupTimer;

  /// Initialize cache service
  Future<void> initialize() async {
    try {
      logging.logger.info('Initializing CacheService');

      _prefs = await SharedPreferences.getInstance();

      // Start periodic cleanup
      _startCleanupTimer();

      // Load critical cache items into memory
      await _loadCriticalCacheItems();

      logging.logger.info('CacheService initialized successfully');
    } catch (e, stackTrace) {
      logging.logger.error('Error initializing CacheService', e, stackTrace);
      ErrorHandler.handleError(e, context: 'CacheService initialization');
      rethrow;
    }
  }

  /// Start cleanup timer to remove expired items
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _cleanupExpiredItems();
    });
  }

  /// Load critical cache items into memory for faster access
  Future<void> _loadCriticalCacheItems() async {
    try {
      final criticalKeys = [
        'user_profile',
        'app_settings',
        'featured_services',
      ];

      for (final key in criticalKeys) {
        final item = await _getFromPersistentStorage(key);
        if (item != null && !item.isExpired) {
          _memoryCache[key] = item;
        }
      }

      logging.logger.debug(
        'Loaded ${_memoryCache.length} critical cache items into memory',
      );
    } catch (e) {
      logging.logger.warning('Error loading critical cache items', e);
    }
  }

  /// Set cache item with TTL
  Future<void> set(
    String key,
    dynamic value, {
    Duration? ttl,
    bool persistent = false,
    bool critical = false,
  }) async {
    try {
      if (key.isEmpty) {
        throw ArgumentError('Cache key cannot be empty');
      }

      final expiration =
          ttl != null
              ? DateTime.now().add(ttl)
              : DateTime.now().add(ConfigService.cacheExpiration);

      final cacheItem = _CacheItem(
        value: value,
        expiration: expiration,
        persistent: persistent,
        critical: critical,
      );

      // Always store in memory cache
      _memoryCache[key] = cacheItem;

      // Store in persistent storage if requested
      if (persistent) {
        await _saveToPersistentStorage(key, cacheItem);
      }

      logging.logger.debug(
        'Cache item set: $key (TTL: ${ttl?.inMinutes ?? ConfigService.cacheExpiration.inMinutes}min, Persistent: $persistent)',
      );
    } catch (e, stackTrace) {
      logging.logger.error('Error setting cache item: $key', e, stackTrace);
      ErrorHandler.handleError(
        e,
        context: 'CacheService.set',
        showToUser: false,
      );
    }
  }

  /// Get cache item
  Future<T?> get<T>(String key) async {
    try {
      if (key.isEmpty) {
        return null;
      }

      // Check memory cache first
      var cacheItem = _memoryCache[key];

      // If not in memory, check persistent storage
      if (cacheItem == null) {
        cacheItem = await _getFromPersistentStorage(key);
        if (cacheItem != null && !cacheItem.isExpired) {
          // Load into memory cache for faster future access
          _memoryCache[key] = cacheItem;
        }
      }

      // Check if item exists and is not expired
      if (cacheItem == null || cacheItem.isExpired) {
        if (cacheItem?.isExpired == true) {
          logging.logger.debug('Cache item expired: $key');
          await remove(key);
        }
        return null;
      }

      logging.logger.debug('Cache hit: $key');
      return cacheItem.value as T?;
    } catch (e, stackTrace) {
      logging.logger.error('Error getting cache item: $key', e, stackTrace);
      ErrorHandler.handleError(
        e,
        context: 'CacheService.get',
        showToUser: false,
      );
      return null;
    }
  }

  /// Check if cache item exists and is not expired
  Future<bool> has(String key) async {
    try {
      final item = await get(key);
      return item != null;
    } catch (e) {
      logging.logger.error('Error checking cache item existence: $key', e);
      return false;
    }
  }

  /// Remove cache item
  Future<void> remove(String key) async {
    try {
      if (key.isEmpty) {
        return;
      }

      // Remove from memory cache
      _memoryCache.remove(key);

      // Remove from persistent storage
      await _removeFromPersistentStorage(key);

      logging.logger.debug('Cache item removed: $key');
    } catch (e, stackTrace) {
      logging.logger.error('Error removing cache item: $key', e, stackTrace);
      ErrorHandler.handleError(
        e,
        context: 'CacheService.remove',
        showToUser: false,
      );
    }
  }

  /// Clear all cache items
  Future<void> clear({bool persistent = true}) async {
    try {
      logging.logger.info('Clearing cache (persistent: $persistent)');

      // Clear memory cache
      _memoryCache.clear();

      // Clear persistent storage if requested
      if (persistent && _prefs != null) {
        final keys =
            _prefs!.getKeys().where((key) => key.startsWith('cache_')).toList();
        for (final key in keys) {
          await _prefs!.remove(key);
        }
      }

      logging.logger.info('Cache cleared successfully');
    } catch (e, stackTrace) {
      logging.logger.error('Error clearing cache', e, stackTrace);
      ErrorHandler.handleError(
        e,
        context: 'CacheService.clear',
        showToUser: false,
      );
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getStatistics() {
    try {
      final memoryItems = _memoryCache.length;
      final expiredItems =
          _memoryCache.values.where((item) => item.isExpired).length;
      final persistentItems =
          _memoryCache.values.where((item) => item.persistent).length;
      final criticalItems =
          _memoryCache.values.where((item) => item.critical).length;

      return {
        'memoryItems': memoryItems,
        'expiredItems': expiredItems,
        'persistentItems': persistentItems,
        'criticalItems': criticalItems,
        'memoryUsage': _estimateMemoryUsage(),
        'lastCleanup': _lastCleanupTime?.toIso8601String(),
      };
    } catch (e) {
      logging.logger.error('Error getting cache statistics', e);
      return {};
    }
  }

  /// Estimate memory usage (rough calculation)
  int _estimateMemoryUsage() {
    try {
      int totalSize = 0;
      for (final item in _memoryCache.values) {
        totalSize += _estimateItemSize(item.value);
      }
      return totalSize;
    } catch (e) {
      logging.logger.error('Error estimating memory usage', e);
      return 0;
    }
  }

  /// Estimate size of a cache item
  int _estimateItemSize(dynamic value) {
    try {
      if (value == null) return 0;
      if (value is String) return value.length * 2; // UTF-16
      if (value is int) return 8;
      if (value is double) return 8;
      if (value is bool) return 1;
      if (value is List) return value.length * 50; // Rough estimate
      if (value is Map) return value.length * 100; // Rough estimate
      return 100; // Default estimate
    } catch (e) {
      return 100;
    }
  }

  /// Save cache item to persistent storage
  Future<void> _saveToPersistentStorage(String key, _CacheItem item) async {
    try {
      if (_prefs == null) return;

      final data = {
        'value': item.value,
        'expiration': item.expiration.millisecondsSinceEpoch,
        'persistent': item.persistent,
        'critical': item.critical,
      };

      await _prefs!.setString('cache_$key', jsonEncode(data));
    } catch (e) {
      logging.logger.error(
        'Error saving cache item to persistent storage: $key',
        e,
      );
    }
  }

  /// Get cache item from persistent storage
  Future<_CacheItem?> _getFromPersistentStorage(String key) async {
    try {
      if (_prefs == null) return null;

      final dataString = _prefs!.getString('cache_$key');
      if (dataString == null) return null;

      final data = jsonDecode(dataString) as Map<String, dynamic>;

      return _CacheItem(
        value: data['value'],
        expiration: DateTime.fromMillisecondsSinceEpoch(data['expiration']),
        persistent: data['persistent'] ?? false,
        critical: data['critical'] ?? false,
      );
    } catch (e) {
      logging.logger.error(
        'Error getting cache item from persistent storage: $key',
        e,
      );
      return null;
    }
  }

  /// Remove cache item from persistent storage
  Future<void> _removeFromPersistentStorage(String key) async {
    try {
      if (_prefs == null) return;
      await _prefs!.remove('cache_$key');
    } catch (e) {
      logging.logger.error(
        'Error removing cache item from persistent storage: $key',
        e,
      );
    }
  }

  DateTime? _lastCleanupTime;

  /// Cleanup expired items
  void _cleanupExpiredItems() {
    try {
      final now = DateTime.now();
      final expiredKeys = <String>[];

      // Find expired items in memory cache
      _memoryCache.forEach((key, item) {
        if (item.isExpired) {
          expiredKeys.add(key);
        }
      });

      // Remove expired items
      for (final key in expiredKeys) {
        _memoryCache.remove(key);
        // Also remove from persistent storage
        _removeFromPersistentStorage(key);
      }

      _lastCleanupTime = now;

      if (expiredKeys.isNotEmpty) {
        logging.logger.debug(
          'Cleaned up ${expiredKeys.length} expired cache items',
        );
      }

      // Memory management: if cache is too large, remove oldest non-critical items
      _manageMemoryUsage();
    } catch (e) {
      logging.logger.error('Error during cache cleanup', e);
    }
  }

  /// Manage memory usage by removing oldest non-critical items
  void _manageMemoryUsage() {
    try {
      const maxItems = 1000; // Maximum items in memory cache

      if (_memoryCache.length <= maxItems) return;

      // Get non-critical items sorted by expiration (oldest first)
      final nonCriticalItems =
          _memoryCache.entries.where((entry) => !entry.value.critical).toList()
            ..sort((a, b) => a.value.expiration.compareTo(b.value.expiration));

      // Remove oldest non-critical items
      final itemsToRemove = _memoryCache.length - maxItems;
      for (int i = 0; i < itemsToRemove && i < nonCriticalItems.length; i++) {
        final key = nonCriticalItems[i].key;
        _memoryCache.remove(key);

        // Keep persistent items in storage
        if (!nonCriticalItems[i].value.persistent) {
          _removeFromPersistentStorage(key);
        }
      }

      if (itemsToRemove > 0) {
        logging.logger.debug(
          'Removed $itemsToRemove items for memory management',
        );
      }
    } catch (e) {
      logging.logger.error('Error during memory management', e);
    }
  }

  // ==================== CONVENIENCE METHODS ====================

  /// Cache user profile
  Future<void> cacheUserProfile(Map<String, dynamic> profile) async {
    await set('user_profile', profile, persistent: true, critical: true);
  }

  /// Get cached user profile
  Future<Map<String, dynamic>?> getCachedUserProfile() async {
    return await get<Map<String, dynamic>>('user_profile');
  }

  /// Cache app settings
  Future<void> cacheAppSettings(Map<String, dynamic> settings) async {
    await set('app_settings', settings, persistent: true, critical: true);
  }

  /// Get cached app settings
  Future<Map<String, dynamic>?> getCachedAppSettings() async {
    return await get<Map<String, dynamic>>('app_settings');
  }

  /// Cache services list
  Future<void> cacheServices(List<Map<String, dynamic>> services) async {
    await set('services_list', services, ttl: const Duration(minutes: 30));
  }

  /// Get cached services
  Future<List<Map<String, dynamic>>?> getCachedServices() async {
    final cached = await get<List<dynamic>>('services_list');
    return cached?.cast<Map<String, dynamic>>();
  }

  /// Cache featured services
  Future<void> cacheFeaturedServices(
    List<Map<String, dynamic>> services,
  ) async {
    await set(
      'featured_services',
      services,
      ttl: const Duration(hours: 1),
      critical: true,
    );
  }

  /// Get cached featured services
  Future<List<Map<String, dynamic>>?> getCachedFeaturedServices() async {
    final cached = await get<List<dynamic>>('featured_services');
    return cached?.cast<Map<String, dynamic>>();
  }

  /// Cache dashboard statistics
  Future<void> cacheDashboardStats(Map<String, dynamic> stats) async {
    await set('dashboard_stats', stats, ttl: const Duration(minutes: 15));
  }

  /// Get cached dashboard statistics
  Future<Map<String, dynamic>?> getCachedDashboardStats() async {
    return await get<Map<String, dynamic>>('dashboard_stats');
  }

  /// Cache API response
  Future<void> cacheApiResponse(
    String endpoint,
    Map<String, dynamic> response, {
    Duration? ttl,
  }) async {
    final key = 'api_${endpoint.replaceAll('/', '_')}';
    await set(key, response, ttl: ttl ?? const Duration(minutes: 10));
  }

  /// Get cached API response
  Future<Map<String, dynamic>?> getCachedApiResponse(String endpoint) async {
    final key = 'api_${endpoint.replaceAll('/', '_')}';
    return await get<Map<String, dynamic>>(key);
  }

  /// Dispose cache service
  void dispose() {
    logging.logger.info('Disposing CacheService');
    _cleanupTimer?.cancel();
    _memoryCache.clear();
  }
}

/// Internal cache item class
class _CacheItem {
  final dynamic value;
  final DateTime expiration;
  final bool persistent;
  final bool critical;

  _CacheItem({
    required this.value,
    required this.expiration,
    this.persistent = false,
    this.critical = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiration);
}
