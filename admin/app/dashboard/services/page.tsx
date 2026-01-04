'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { useSupabase } from '../../providers'
import {
  PlusIcon,
  PencilIcon,
  TrashIcon,
  MagnifyingGlassIcon,
  BuildingStorefrontIcon,
} from '@heroicons/react/24/outline'

interface Service {
  id: string
  title: string
  description: string
  price: number
  category: string
  image_url: string | null
  is_active: boolean
  created_at: string
  features: string[]
  duration: string | null
  location: string | null
}

export default function ServicesPage() {
  const { supabase } = useSupabase()
  const [services, setServices] = useState<Service[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [categoryFilter, setCategoryFilter] = useState('all')

  useEffect(() => {
    fetchServices()
  }, [])

  const fetchServices = async () => {
    try {
      const { data, error } = await supabase
        .from('services')
        .select('*')
        .order('created_at', { ascending: false })

      if (error) throw error
      setServices(data || [])
    } catch (error) {
      console.error('Error fetching services:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleDeleteService = async (serviceId: string) => {
    if (!confirm('Are you sure you want to delete this service?')) return

    try {
      const { error } = await supabase
        .from('services')
        .delete()
        .eq('id', serviceId)

      if (error) throw error
      
      setServices(services.filter(service => service.id !== serviceId))
      alert('Service deleted successfully')
    } catch (error) {
      console.error('Error deleting service:', error)
      alert('Error deleting service')
    }
  }

  const toggleServiceStatus = async (serviceId: string, currentStatus: boolean) => {
    try {
      const { error } = await supabase
        .from('services')
        .update({ is_active: !currentStatus })
        .eq('id', serviceId)

      if (error) throw error
      
      setServices(services.map(service => 
        service.id === serviceId ? { ...service, is_active: !currentStatus } : service
      ))
    } catch (error) {
      console.error('Error updating service status:', error)
      alert('Error updating service status')
    }
  }

  const categories = [...new Set(services.map(service => service.category))]

  const filteredServices = services.filter(service => {
    const matchesSearch = service.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         service.description.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesCategory = categoryFilter === 'all' || service.category === categoryFilter
    return matchesSearch && matchesCategory
  })

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
          <h1 className="text-2xl font-bold text-gray-900">Services Management</h1>
          <p className="text-gray-600">Manage all services offered by Kronium</p>
        </div>
        <Link
          href="/dashboard/services/create"
          className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700"
        >
          <PlusIcon className="h-4 w-4 mr-2" />
          Add Service
        </Link>
      </div>

      {/* Filters */}
      <div className="bg-white p-4 rounded-lg shadow">
        <div className="flex flex-col sm:flex-row gap-4">
          <div className="flex-1">
            <div className="relative">
              <MagnifyingGlassIcon className="h-5 w-5 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                placeholder="Search services..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
              />
            </div>
          </div>
          <div>
            <select
              value={categoryFilter}
              onChange={(e) => setCategoryFilter(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
            >
              <option value="all">All Categories</option>
              {categories.map(category => (
                <option key={category} value={category}>{category}</option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Services Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredServices.map((service) => (
          <div key={service.id} className="bg-white rounded-lg shadow hover:shadow-md transition-shadow">
            {/* Service Image */}
            <div className="h-48 bg-gray-200 rounded-t-lg flex items-center justify-center">
              {service.image_url ? (
                <img
                  src={service.image_url}
                  alt={service.title}
                  className="w-full h-full object-cover rounded-t-lg"
                />
              ) : (
                <BuildingStorefrontIcon className="h-16 w-16 text-gray-400" />
              )}
            </div>

            {/* Service Content */}
            <div className="p-6">
              <div className="flex justify-between items-start mb-2">
                <h3 className="text-lg font-semibold text-gray-900 truncate">{service.title}</h3>
                <button
                  onClick={() => toggleServiceStatus(service.id, service.is_active)}
                  className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full cursor-pointer ${
                    service.is_active 
                      ? 'bg-green-100 text-green-800 hover:bg-green-200' 
                      : 'bg-red-100 text-red-800 hover:bg-red-200'
                  }`}
                >
                  {service.is_active ? 'Active' : 'Inactive'}
                </button>
              </div>

              <p className="text-gray-600 text-sm mb-3 line-clamp-2">{service.description}</p>

              <div className="space-y-2 mb-4">
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-500">Price:</span>
                  <span className="text-lg font-bold text-primary-600">${service.price}</span>
                </div>
                
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-500">Category:</span>
                  <span className="text-sm font-medium text-gray-900">{service.category}</span>
                </div>

                {service.duration && (
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-gray-500">Duration:</span>
                    <span className="text-sm text-gray-900">{service.duration}</span>
                  </div>
                )}

                {service.location && (
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-gray-500">Location:</span>
                    <span className="text-sm text-gray-900">{service.location}</span>
                  </div>
                )}
              </div>

              {/* Features */}
              {service.features && service.features.length > 0 && (
                <div className="mb-4">
                  <span className="text-sm text-gray-500 block mb-1">Features:</span>
                  <div className="flex flex-wrap gap-1">
                    {service.features.slice(0, 3).map((feature, index) => (
                      <span
                        key={index}
                        className="inline-flex px-2 py-1 text-xs bg-gray-100 text-gray-700 rounded"
                      >
                        {feature}
                      </span>
                    ))}
                    {service.features.length > 3 && (
                      <span className="inline-flex px-2 py-1 text-xs bg-gray-100 text-gray-700 rounded">
                        +{service.features.length - 3} more
                      </span>
                    )}
                  </div>
                </div>
              )}

              {/* Actions */}
              <div className="flex justify-between items-center pt-4 border-t border-gray-200">
                <span className="text-xs text-gray-500">
                  Created {new Date(service.created_at).toLocaleDateString()}
                </span>
                <div className="flex space-x-2">
                  <Link
                    href={`/dashboard/services/${service.id}/edit`}
                    className="text-primary-600 hover:text-primary-900 p-1"
                  >
                    <PencilIcon className="h-4 w-4" />
                  </Link>
                  <button
                    onClick={() => handleDeleteService(service.id)}
                    className="text-red-600 hover:text-red-900 p-1"
                  >
                    <TrashIcon className="h-4 w-4" />
                  </button>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {filteredServices.length === 0 && (
        <div className="text-center py-12">
          <BuildingStorefrontIcon className="mx-auto h-12 w-12 text-gray-400" />
          <h3 className="mt-2 text-sm font-medium text-gray-900">No services found</h3>
          <p className="mt-1 text-sm text-gray-500">
            {searchTerm || categoryFilter !== 'all' 
              ? 'Try adjusting your search or filter criteria.'
              : 'Get started by creating a new service.'
            }
          </p>
          {!searchTerm && categoryFilter === 'all' && (
            <div className="mt-6">
              <Link
                href="/dashboard/services/create"
                className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700"
              >
                <PlusIcon className="h-4 w-4 mr-2" />
                Add Service
              </Link>
            </div>
          )}
        </div>
      )}
    </div>
  )
}