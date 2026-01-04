'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { useSupabase } from '../app/providers'
import {
  HomeIcon,
  UsersIcon,
  CogIcon,
  ChartBarIcon,
  CalendarIcon,
  ChatBubbleLeftRightIcon,
  BuildingStorefrontIcon,
  ArrowRightOnRectangleIcon,
  Bars3Icon,
  XMarkIcon,
} from '@heroicons/react/24/outline'

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: HomeIcon },
  { name: 'Users', href: '/dashboard/users', icon: UsersIcon },
  { name: 'Services', href: '/dashboard/services', icon: BuildingStorefrontIcon },
  { name: 'Bookings', href: '/dashboard/bookings', icon: CalendarIcon },
  { name: 'Projects', href: '/dashboard/projects', icon: CogIcon },
  { name: 'Chat', href: '/dashboard/chat', icon: ChatBubbleLeftRightIcon },
  { name: 'Analytics', href: '/dashboard/analytics', icon: ChartBarIcon },
]

export default function Sidebar() {
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const pathname = usePathname()
  const { supabase, user } = useSupabase()

  // Close sidebar on route change (mobile)
  useEffect(() => {
    setSidebarOpen(false)
  }, [pathname])

  // Close sidebar on escape key
  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        setSidebarOpen(false)
      }
    }
    
    if (sidebarOpen) {
      document.addEventListener('keydown', handleEscape)
      document.body.style.overflow = 'hidden'
    } else {
      document.body.style.overflow = 'unset'
    }

    return () => {
      document.removeEventListener('keydown', handleEscape)
      document.body.style.overflow = 'unset'
    }
  }, [sidebarOpen])

  const handleLogout = async () => {
    await supabase.auth.signOut()
  }

  return (
    <>
      {/* Mobile sidebar overlay */}
      <div 
        className={`fixed inset-0 z-50 lg:hidden transition-opacity duration-300 ${
          sidebarOpen ? 'opacity-100' : 'opacity-0 pointer-events-none'
        }`}
      >
        <div 
          className="fixed inset-0 bg-gray-600 bg-opacity-75 transition-opacity" 
          onClick={() => setSidebarOpen(false)} 
        />
        <div className={`fixed inset-y-0 left-0 flex w-64 flex-col bg-white shadow-xl transform transition-transform duration-300 ease-in-out ${
          sidebarOpen ? 'translate-x-0' : '-translate-x-full'
        }`}>
          <div className="flex h-16 items-center justify-between px-4 border-b border-gray-200">
            <h1 className="text-xl font-bold text-primary-600">Kronium Admin</h1>
            <button
              onClick={() => setSidebarOpen(false)}
              className="text-gray-400 hover:text-gray-600 p-1 rounded-md hover:bg-gray-100 transition-colors"
            >
              <XMarkIcon className="h-6 w-6" />
            </button>
          </div>
          <SidebarContent pathname={pathname} onLogout={handleLogout} user={user} />
        </div>
      </div>

      {/* Desktop sidebar */}
      <div className="hidden lg:fixed lg:inset-y-0 lg:flex lg:w-64 lg:flex-col lg:z-40">
        <div className="flex flex-col flex-grow bg-white border-r border-gray-200 shadow-sm">
          <div className="flex h-16 items-center px-4 border-b border-gray-200">
            <h1 className="text-xl font-bold text-primary-600">Kronium Admin</h1>
          </div>
          <SidebarContent pathname={pathname} onLogout={handleLogout} user={user} />
        </div>
      </div>

      {/* Mobile menu button */}
      <div className="lg:hidden fixed top-4 left-4 z-50">
        <button
          onClick={() => setSidebarOpen(true)}
          className="p-2 bg-white rounded-md shadow-lg border border-gray-200 hover:bg-gray-50 transition-colors"
          aria-label="Open sidebar"
        >
          <Bars3Icon className="h-6 w-6 text-gray-600" />
        </button>
      </div>
    </>
  )
}

function SidebarContent({ pathname, onLogout, user }: { 
  pathname: string
  onLogout: () => void
  user: any
}) {
  return (
    <div className="flex flex-col flex-grow min-h-0">
      <nav className="flex-1 px-4 py-4 space-y-1 overflow-y-auto">
        {navigation.map((item) => {
          const isActive = pathname === item.href || pathname.startsWith(item.href + '/')
          return (
            <Link
              key={item.name}
              href={item.href}
              className={`group flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-all duration-200 ${
                isActive
                  ? 'bg-primary-100 text-primary-900 shadow-sm'
                  : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
              }`}
            >
              <item.icon
                className={`mr-3 h-5 w-5 flex-shrink-0 transition-colors ${
                  isActive ? 'text-primary-600' : 'text-gray-400 group-hover:text-gray-500'
                }`}
              />
              <span className="truncate">{item.name}</span>
            </Link>
          )
        })}
      </nav>

      {/* User info and logout */}
      <div className="border-t border-gray-200 p-4 bg-gray-50">
        <div className="flex items-center mb-3">
          <div className="flex-shrink-0">
            <div className="h-10 w-10 bg-primary-600 rounded-full flex items-center justify-center">
              <span className="text-sm font-medium text-white">
                {user?.email?.charAt(0).toUpperCase() || 'A'}
              </span>
            </div>
          </div>
          <div className="ml-3 min-w-0 flex-1">
            <p className="text-sm font-medium text-gray-700 truncate">
              {user?.email || 'Admin User'}
            </p>
            <p className="text-xs text-gray-500">Administrator</p>
          </div>
        </div>
        <button
          onClick={onLogout}
          className="w-full flex items-center px-3 py-2 text-sm font-medium text-gray-600 rounded-lg hover:bg-white hover:text-gray-900 transition-all duration-200 border border-transparent hover:border-gray-200 hover:shadow-sm"
        >
          <ArrowRightOnRectangleIcon className="mr-3 h-5 w-5 text-gray-400 flex-shrink-0" />
          <span>Sign out</span>
        </button>
      </div>
    </div>
  )
}