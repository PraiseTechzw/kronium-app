import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'KRONIUM';
  static const String appVersion = '1.0.0';
  
  // Animation paths
  static const String splashAnimation = 'assets/animations/splash_wave.json';
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String successAnimation = 'assets/animations/success.json';
  
  // Image paths
  static const String appLogo = 'assets/images/logo.png';
  static const String loginHeader = 'assets/images/login_header.png';
  
  // API Endpoints (example)
  static const String baseUrl = 'https://api.kronium.com';
  static const String loginEndpoint = '$baseUrl/auth/login';

  static String? loginAnimation;

  static final List<Map<String, dynamic>> companySlidesData = [
    {
      'title': 'POWERING THE FUTURE',
      'subtitle': 'Kronium Engineering',
      'body': 'An independent firm of designers, architects, planners, engineers, environmental specialists, agronomists and electricians offering a broad range of professional services.',
      'icon': Icons.flash_on,
      'logo': 'assets/images/logo.png',
    },
    {
      'title': 'ABOUT KRONIUM ENGINEERING',
      'body': 'Since its founding, Kronium has established a worldwide network of specialists, enabling us to offer complete customized solutions in renewable energy, engineering projects, and the commercialized industry.',
      'icon': Icons.info_outline,
    },
    {
      'title': 'OUR VISION',
      'body': 'Provide energy in an innovative and responsible way for the benefit of all.',
      'icon': Icons.visibility_outlined,
    },
    {
      'title': 'OUR MISSION',
      'body': 'To ensure equitable energy distribution in a sustainable way globally.',
      'icon': Icons.flag_outlined,
    },
    {
      'title': 'BUSINESS ACHIEVEMENTS',
      'body': [
        'Construction of greenhouses across Zimbabwe.',
        'Solar Systems installations in Harare residential areas.',
        'Borehole drilling and irrigation systems across Zimbabwe.',
        'Access to making solar panels through offtake agreements with business angels and investors.',
        'Access to funding through Africa\'s key development financial institutions and the Diaspora.',
        'Unlimited government support from the Zimbabwean government.'
      ],
      'icon': Icons.emoji_events_outlined,
    },
    {
      'title': 'CORE VALUES',
      'body': [
        'Passion First',
        'Employee Empowerment',
        'Teamwork',
        'Integrity',
        'Innovation',
        'Customer Focus',
        'Excellence',
      ],
      'icon': Icons.star_outline,
    },
    {
      'title': 'OUR SERVICES',
      'body': [
        'Greenhouse Construction',
        'Irrigation Systems',
        'Borehole Siting',
        'Borehole Drilling',
        'Solar System & Installation',
        'AC & DC Pump Installation',
      ],
      'icon': Icons.build_outlined,
    },
    {
      'title': 'HOW WE WORK',
      'body': 'Kronium Engineering works across the whole renewable energy and engineering field offering a one stop shop from installation, distribution, assembling, manufacturing of materials.',
      'icon': Icons.handshake_outlined,
    },
    {
      'title': 'OUR PROGRAMS',
      'body': [
        'Engineering Solutions for Churches (ES4C)',
        'Educational Institutions (ES4EI)',
        'Health Institutions (ES4HI)',
        'Local Authorities (ES4LA)',
        'Industry (ES4I)',
        'Farms, Wastelands & Water Bodys (ES4FWW)',
        'Mines (ES4M)',
        'ICT (ES4ICT)',
        'Homes (ES4H)',
        'Offices and Shopping Malls (ES4OSM)',
        'Waste Management Systems',
        'Farm Structures',
      ],
      'icon': Icons.apps_outlined,
    },
    {
      'title': 'OUR TEAM',
      'body': 'Key promoters: Arthur, George, Jubilee.\nThe company operates with all staff coming in by project need.\nA full-fledged management team will be put in place as finances allow.',
      'icon': Icons.group_outlined,
    },
    {
      'title': 'CONTACT & OFFICES',
      'body': [
        {'type': 'phone', 'value': '+263 784 148 718'},
        {'type': 'phone', 'value': '+263 713 017 885'},
        {'type': 'email', 'value': 'projects@kronium.co.zw'},
        {'type': 'address', 'value': 'No. 174 Gleneagles, Harare, Zimbabwe'},
        {'type': 'address', 'value': 'Global Office: Worldwide'},
      ],
      'icon': Icons.contact_phone_outlined,
      'socials': [
        {'icon': Icons.facebook, 'url': 'https://facebook.com'},
        {'icon': Icons.linked_camera, 'url': 'https://linkedin.com'},
        {'icon': Icons.web, 'url': 'https://kronium.co.zw'},
      ],
    },
    {
      'title': 'OUR PROJECTS',
      'body': [
        'GREENHOUSES',
        'P. Nzvenga 250 SQM unit +263772965535',
        'Mrs Munemo 250 SQM unit +263772891550',
        'Prevail International 1000 SQM unit +263772977382',
        'AT. Maigwa 500 SQM unit +447471312187',
        'Denartis 400 SQM unit +263785486604',
        'FARM STRUCTURES',
        'T. CHIGODO 192 SQM SHED +27 (0)826545788',
        'BOREHOLE DRILLING AND INSTALLATION',
        'N. ZVIDZA BOREHOLE DRILLING +263777258832',
        'MRS TARANHIKE 90 SQM +263774119745',
      ],
      'icon': Icons.work_outline,
    },
  ];
}