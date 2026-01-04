'use client'

import { useEffect, useState } from 'react'
import { useSupabase } from '../../providers'
import {
  ChartBarIcon,
  UsersIcon,
  BuildingStorefrontIcon,
  CalendarIcon,
  CurrencyDollarIcon,
  TrendingUpIcon,
  TrendingDownIcon,
} from '@heroicons/react/24/outline'

interface AnalyticsData {
  totalUsers: number
  totalServices: number
  totalBookings: number
  totalRevenue: number
  monthlyBookings: { month: string; count: number }[]
  serviceCategories: { category: string; count: number }[]
  recentGrowth: {
    users: number
    bookings: number
    revenue: number
  }
  topServices: { title: string; bookings: number; revenue: number }[]
}

export default function AnalyticsPage() {
  const { supabase } = useSupabase()
  const [analytics, setAnalytics] = useState<AnalyticsData>({
    totalUsers: 0,
    totalServices: 0,
    totalBookings: 0,
    totalRevenue: 0,
    monthlyBookings: [],
    serviceCategories: [],
    recentGrowth: { users: 0, bookings: 0, revenue: 0 },
    topServices: [],
  })
  const [loading, setLoading] = useState(true)
  const [timeRange, setTimeRange] = useState('30') // days

  useEffect(() => {
    fetchAnalytics()
  }, [timeRange])

  const fetchAnalytics = async () => {
    try {
      setLoading(true)
      
      // Calculate date range
      const endDate = new Date()
      const startDate = new Date()
      startDate.setDate(startDate.getDate() - parseInt(timeRange))

      // Fetch basic counts
      const [usersResult, servicesResult, bookingsResult] = await Promise.all([
        supabase.from('users').select('*', { count: 'exact', head: true }),
        supabase.from('services').select('*', { count: 'exact', head: true }),
        supabase.from('bookings').select('*', { count: 'exact', head: true }),
      ])

      // Fetch bookings with details for revenue calculation
      const { data: bookingsData } = await supabase
        .from('bookings')
        .select(`
          *,
          services(title, price, category)
        `)
        .gte('created_at', startDate.toISOString())

      // Calculate revenue
      const totalRevenue = bookingsData?.reduce((sum, booking) => {
        return sum + (booking.total_amount || booking.services?.price || 0)
      }, 0) || 0

      // Monthly bookings trend
      const monthlyBookings = getMonthlyBookings(bookingsData || [])

      // Service categories distribution
      const serviceCategories = getServiceCategories(bookingsData || [])

      // Top services
      const topServices = getTopServices(bookingsData || [])

      // Calculate growth (comparing with previous period)
      const previousStartDate = new Date(startDate)
      previousStartDate.setDate(previousStartDate.getDate() - parseInt(timeRange))
      
      const { data: previousBookings } = await supabase
        .from('bookings')
        .select('*')
        .gte('created_at', previousStartDate.toISOString())
        .lt('created_at', startDate.toISOString())

      const { data: previousUsers } = await supabase
        .from('users')
        .select('*')
        .gte('created_at', previousStartDate.toISOString())
        .lt('created_at', startDate.toISOString())

      const currentPeriodBookings = bookingsData?.length || 0
      const previousPeriodBookings = previousBookings?.length || 0
      const currentPeriodUsers = await supabase
        .from('users')
        .select('*')
        .gte('created_at', startDate.toISOString())
      
      const recentGrowth = {
        users: previousUsers?.length ? 
          ((currentPeriodUsers.data?.length || 0) - previousUsers.length) / previousUsers.length * 100 : 0,
        bookings: previousPeriodBookings ? 
          (currentPeriodBookings - previousPeriodBookings) / previousPeriodBookings * 100 : 0,
        revenue: 0 // Simplified for now
      }

      setAnalytics({
        totalUsers: usersResult.count || 0,
        totalServices: servicesResult.count || 0,
        totalBookings: bookingsResult.count || 0,
        totalRevenue,
        monthlyBookings,
        serviceCategories,
        recentGrowth,
        topServices,
      })
    } catch (error) {
      console.error('Error fetching analytics:', error)
    } finally {
      setLoading(false)
    }
  }

  const getMonthlyBookings = (bookings: any[]) => {
    const monthCounts: { [key: string]: number } = {}
    
    bookings.forEach(booking => {
      const month = new Date(booking.created_at).toLocaleDateString('en-US', { 
        year: 'numeric', 
        month: 'short' 
      })
      monthCounts[month] = (monthCounts[month] || 0) + 1
    })

    return Object.entries(monthCounts)
      .map(([month, count]) => ({ month, count }))
      .sort((a, b) => new Date(a.month).getTime() - new Date(b.month).getTime())
  }

  const getServiceCategories = (bookings: any[]) => {
    const categoryCounts: { [key: string]: number } = {}
    
    bookings.forEach(booking => {
      const category = booking.services?.category || 'Unknown'
      categoryCounts[category] = (categoryCounts[category] || 0) + 1
    })

    return Object.entries(categoryCounts)
      .map(([category, count]) => ({ category, count }))
      .sort((a, b) => b.count - a.count)
  }

  const getTopServices = (bookings: any[]) => {
    const serviceCounts: { [key: string]: { bookings: number; revenue: number; title: string } } = {}
    
    bookings.forEach(booking => {
      const serviceId = booking.service_id
      const title = booking.services?.title || 'Unknown Service'
      const revenue = booking.total_amount || booking.services?.price || 0
      
      if (!serviceCounts[serviceId]) {
        serviceCounts[serviceId] = { bookings: 0, revenue: 0, title }
      }
      
      serviceCounts[serviceId].bookings += 1
      serviceCounts[serviceId].revenue += revenue
    })

    return Object.values(serviceCounts)
      .sort((a, b) => b.bookings - a.bookings)
      .slice(0, 5)
  }

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount)
  }

  const formatPercentage = (value: number) => {
    return `${value >= 0 ? '+' : ''}${value.toFixed(1)}%`
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Analytics Dashboard</h1>
          <p className="text-gray-600">Track your business performance and insights</p>
        </div>
        <div>
          <select
            value={timeRange}
            onChange={(e) => setTimeRange(e.target.value)}
            className="px-4 py-2 border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
          >
            <option value="7">Last 7 days</option>
            <option value="30">Last 30 days</option>
            <option value="90">Last 90 days</option>
            <option value="365">Last year</option>
          </select>
        </div>
      </div>

      {/* Key Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="bg-white p-6 rounded-lg shadow">
          <div className="flex items-center">
            <div className="p-2 bg-blue-100 rounded-lg">
              <UsersIcon className="h-6 w-6 text-blue-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Total Users</p>
              <p className="text-2xl font-bold text-gray-900">{analytics.totalUsers}</p>
              <div className="flex items-center mt-1">
                {analytics.recentGrowth.users >= 0 ? (
                  <TrendingUpIcon className="h-4 w-4 text-green-500" />
                ) : (
                  <TrendingDownIcon className="h-4 w-4 text-red-500" />
                )}
                <span className={`text-sm ml-1 ${
                  analytics.recentGrowth.users >= 0 ? 'text-green-600' : 'text-red-600'
                }`}>
                  {formatPercentage(analytics.recentGrowth.users)}
                </span>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow">
          <div className="flex items-center">
            <div className="p-2 bg-green-100 rounded-lg">
              <BuildingStorefrontIcon className="h-6 w-6 text-green-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Total Services</p>
              <p className="text-2xl font-bold text-gray-900">{analytics.totalServices}</p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow">
          <div className="flex items-center">
            <div className="p-2 bg-yellow-100 rounded-lg">
              <CalendarIcon className="h-6 w-6 text-yellow-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Total Bookings</p>
              <p className="text-2xl font-bold text-gray-900">{analytics.totalBookings}</p>
              <div className="flex items-center mt-1">
                {analytics.recentGrowth.bookings >= 0 ? (
                  <TrendingUpIcon className="h-4 w-4 text-green-500" />
                ) : (
                  <TrendingDownIcon className="h-4 w-4 text-red-500" />
                )}
                <span className={`text-sm ml-1 ${
                  analytics.recentGrowth.bookings >= 0 ? 'text-green-600' : 'text-red-600'
                }`}>
                  {formatPercentage(analytics.recentGrowth.bookings)}
                </span>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow">
          <div className="flex items-center">
            <div className="p-2 bg-purple-100 rounded-lg">
              <CurrencyDollarIcon className="h-6 w-6 text-purple-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Total Revenue</p>
              <p className="text-2xl font-bold text-gray-900">{formatCurrency(analytics.totalRevenue)}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Monthly Bookings Trend */}
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Bookings Trend</h3>
          <div className="space-y-3">
            {analytics.monthlyBookings.map((item, index) => (
              <div key={index} className="flex items-center justify-between">
                <span className="text-sm text-gray-600">{item.month}</span>
                <div className="flex items-center">
                  <div className="w-32 bg-gray-200 rounded-full h-2 mr-3">
                    <div
                      className="bg-primary-600 h-2 rounded-full"
                      style={{
                        width: `${Math.max(10, (item.count / Math.max(...analytics.monthlyBookings.map(m => m.count))) * 100)}%`
                      }}
                    ></div>
                  </div>
                  <span className="text-sm font-medium text-gray-900">{item.count}</span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Service Categories */}
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Popular Categories</h3>
          <div className="space-y-3">
            {analytics.serviceCategories.slice(0, 6).map((item, index) => (
              <div key={index} className="flex items-center justify-between">
                <span className="text-sm text-gray-600">{item.category}</span>
                <div className="flex items-center">
                  <div className="w-32 bg-gray-200 rounded-full h-2 mr-3">
                    <div
                      className="bg-green-600 h-2 rounded-full"
                      style={{
                        width: `${Math.max(10, (item.count / Math.max(...analytics.serviceCategories.map(c => c.count))) * 100)}%`
                      }}
                    ></div>
                  </div>
                  <span className="text-sm font-medium text-gray-900">{item.count}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Top Services */}
      <div className="bg-white shadow rounded-lg">
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg font-medium text-gray-900">Top Performing Services</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Service
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Bookings
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Revenue
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Avg. per Booking
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {analytics.topServices.map((service, index) => (
                <tr key={index}>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{service.title}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{service.bookings}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{formatCurrency(service.revenue)}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">
                      {formatCurrency(service.revenue / service.bookings)}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {analytics.topServices.length === 0 && (
          <div className="text-center py-12">
            <ChartBarIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">No data available</h3>
            <p className="mt-1 text-sm text-gray-500">
              Service performance data will appear here once you have bookings.
            </p>
          </div>
        )}
      </div>
    </div>
  )
}