'use client'

import { useEffect, useState } from 'react'
import { useSupabase } from '../providers'
import {
  UsersIcon,
  BuildingStorefrontIcon,
  CalendarIcon,
  CogIcon,
  ChartBarIcon,
  ArrowUpIcon,
  ArrowDownIcon,
} from '@heroicons/react/24/outline'

interface DashboardStats {
  totalUsers: number
  totalServices: number
  totalBookings: number
  totalProjects: number
  recentBookings: any[]
  recentUsers: any[]
}

export default function DashboardPage() {
  const { supabase } = useSupabase()
  const [stats, setStats] = useState<DashboardStats>({
    totalUsers: 0,
    totalServices: 0,
    totalBookings: 0,
    totalProjects: 0,
    recentBookings: [],
    recentUsers: [],
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchDashboardData()
  }, [])

  const fetchDashboardData = async () => {
    try {
      // Fetch counts
      const [usersResult, servicesResult, bookingsResult, projectsResult] = await Promise.all([
        supabase.from('users').select('*', { count: 'exact', head: true }),
        supabase.from('services').select('*', { count: 'exact', head: true }),
        supabase.from('bookings').select('*', { count: 'exact', head: true }),
        supabase.from('projects').select('*', { count: 'exact', head: true }),
      ])

      // Fetch recent data
      const [recentBookingsResult, recentUsersResult] = await Promise.all([
        supabase
          .from('bookings')
          .select(`
            *,
            users(name, email),
            services(title)
          `)
          .order('created_at', { ascending: false })
          .limit(5),
        supabase
          .from('users')
          .select('*')
          .order('created_at', { ascending: false })
          .limit(5),
      ])

      setStats({
        totalUsers: usersResult.count || 0,
        totalServices: servicesResult.count || 0,
        totalBookings: bookingsResult.count || 0,
        totalProjects: projectsResult.count || 0,
        recentBookings: recentBookingsResult.data || [],
        recentUsers: recentUsersResult.data || [],
      })
    } catch (error) {
      console.error('Error fetching dashboard data:', error)
    } finally {
      setLoading(false)
    }
  }

  const statCards = [
    {
      name: 'Total Users',
      value: stats.totalUsers,
      icon: UsersIcon,
      change: '+12%',
      changeType: 'increase',
      href: '/dashboard/users',
    },
    {
      name: 'Active Services',
      value: stats.totalServices,
      icon: BuildingStorefrontIcon,
      change: '+5%',
      changeType: 'increase',
      href: '/dashboard/services',
    },
    {
      name: 'Total Bookings',
      value: stats.totalBookings,
      icon: CalendarIcon,
      change: '+18%',
      changeType: 'increase',
      href: '/dashboard/bookings',
    },
    {
      name: 'Active Projects',
      value: stats.totalProjects,
      icon: CogIcon,
      change: '+8%',
      changeType: 'increase',
      href: '/dashboard/projects',
    },
  ]

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
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard Overview</h1>
        <p className="text-gray-600">Welcome to your Kronium admin dashboard</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {statCards.map((card) => (
          <div
            key={card.name}
            className="relative bg-white p-4 sm:p-6 shadow-sm rounded-xl border border-gray-100 hover:shadow-md hover:border-primary-200 transition-all duration-200 cursor-pointer group"
            onClick={() => window.location.href = card.href}
          >
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <div className="p-3 bg-primary-500 rounded-lg group-hover:bg-primary-600 transition-colors">
                  <card.icon className="h-6 w-6 text-white" aria-hidden="true" />
                </div>
              </div>
              <div className="ml-4 flex-1 min-w-0">
                <p className="text-sm font-medium text-gray-600 truncate">{card.name}</p>
                <div className="flex items-baseline mt-1">
                  <p className="text-2xl font-bold text-gray-900">{card.value}</p>
                  <p
                    className={`ml-2 flex items-center text-sm font-semibold ${
                      card.changeType === 'increase' ? 'text-green-600' : 'text-red-600'
                    }`}
                  >
                    {card.changeType === 'increase' ? (
                      <ArrowUpIcon className="h-4 w-4 mr-1" />
                    ) : (
                      <ArrowDownIcon className="h-4 w-4 mr-1" />
                    )}
                    {card.change}
                  </p>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Recent Activity */}
      <div className="grid grid-cols-1 xl:grid-cols-2 gap-6">
        {/* Recent Bookings */}
        <div className="bg-white shadow-sm rounded-xl border border-gray-100">
          <div className="px-4 py-5 sm:p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Bookings</h3>
            <div className="space-y-3">
              {stats.recentBookings.length > 0 ? (
                stats.recentBookings.map((booking) => (
                  <div key={booking.id} className="flex flex-col sm:flex-row sm:items-center sm:justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                    <div className="mb-2 sm:mb-0">
                      <p className="text-sm font-medium text-gray-900">
                        {booking.users?.name || 'Unknown User'}
                      </p>
                      <p className="text-sm text-gray-500">{booking.services?.title || 'Unknown Service'}</p>
                    </div>
                    <div className="flex justify-between sm:block sm:text-right">
                      <p className={`text-sm font-medium ${
                        booking.status === 'confirmed' ? 'text-green-600' :
                        booking.status === 'pending' ? 'text-yellow-600' :
                        'text-gray-600'
                      }`}>
                        {booking.status}
                      </p>
                      <p className="text-xs text-gray-500">
                        {new Date(booking.created_at).toLocaleDateString()}
                      </p>
                    </div>
                  </div>
                ))
              ) : (
                <div className="text-center py-8">
                  <CalendarIcon className="mx-auto h-12 w-12 text-gray-400" />
                  <p className="text-gray-500 text-sm mt-2">No recent bookings</p>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Recent Users */}
        <div className="bg-white shadow-sm rounded-xl border border-gray-100">
          <div className="px-4 py-5 sm:p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Users</h3>
            <div className="space-y-3">
              {stats.recentUsers.length > 0 ? (
                stats.recentUsers.map((user) => (
                  <div key={user.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                    <div className="flex items-center min-w-0 flex-1">
                      <div className="h-10 w-10 bg-primary-600 rounded-full flex items-center justify-center flex-shrink-0">
                        <span className="text-sm font-medium text-white">
                          {user.name?.charAt(0).toUpperCase()}
                        </span>
                      </div>
                      <div className="ml-3 min-w-0 flex-1">
                        <p className="text-sm font-medium text-gray-900 truncate">{user.name}</p>
                        <p className="text-sm text-gray-500 truncate">{user.email}</p>
                      </div>
                    </div>
                    <div className="text-right flex-shrink-0">
                      <p className={`text-sm font-medium ${
                        user.is_active ? 'text-green-600' : 'text-red-600'
                      }`}>
                        {user.is_active ? 'Active' : 'Inactive'}
                      </p>
                      <p className="text-xs text-gray-500">
                        {new Date(user.created_at).toLocaleDateString()}
                      </p>
                    </div>
                  </div>
                ))
              ) : (
                <div className="text-center py-8">
                  <UsersIcon className="mx-auto h-12 w-12 text-gray-400" />
                  <p className="text-gray-500 text-sm mt-2">No recent users</p>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="bg-white shadow-sm rounded-xl border border-gray-100">
        <div className="px-4 py-5 sm:p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
            <button
              onClick={() => window.location.href = '/dashboard/users/create'}
              className="flex items-center justify-center px-4 py-3 border border-transparent text-sm font-medium rounded-lg text-white bg-primary-600 hover:bg-primary-700 transition-all duration-200 hover:shadow-md"
            >
              <UsersIcon className="h-4 w-4 mr-2 flex-shrink-0" />
              <span>Add User</span>
            </button>
            <button
              onClick={() => window.location.href = '/dashboard/services/create'}
              className="flex items-center justify-center px-4 py-3 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50 transition-all duration-200 hover:shadow-md"
            >
              <BuildingStorefrontIcon className="h-4 w-4 mr-2 flex-shrink-0" />
              <span>Add Service</span>
            </button>
            <button
              onClick={() => window.location.href = '/dashboard/bookings'}
              className="flex items-center justify-center px-4 py-3 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50 transition-all duration-200 hover:shadow-md"
            >
              <CalendarIcon className="h-4 w-4 mr-2 flex-shrink-0" />
              <span>View Bookings</span>
            </button>
            <button
              onClick={() => window.location.href = '/dashboard/analytics'}
              className="flex items-center justify-center px-4 py-3 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50 transition-all duration-200 hover:shadow-md"
            >
              <ChartBarIcon className="h-4 w-4 mr-2 flex-shrink-0" />
              <span>Analytics</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}