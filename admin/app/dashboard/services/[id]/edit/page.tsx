'use client'

import { useState, useEffect } from 'react'
import { useRouter, useParams } from 'next/navigation'
import { useSupabase } from '../../../../providers'
import { useToast } from '../../../../../components/ToastContainer'
import { ImageUpload } from '../../../../../components/ImageUpload'
import {
  ArrowLeftIcon,
  BuildingStorefrontIcon,
} from '@heroicons/react/24/outline'

interface Service {
  id: string
  title: string
  description: string
  price: number
  category: string
  image_url: string | null
  image_path: string | null
  is_active: boolean
  features: string[]
  duration: string | null
  location: string | null
}

export default function EditServicePage() {
  const { supabase } = useSupabase()
  const { showSuccess, showError, showInfo } = useToast()
  const router = useRouter()
  const params = useParams()
  const serviceId = params.id as string
  
  const [loading, setLoading] = useState(false)
  const [initialLoading, setInitialLoading] = useState(true)
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    price: '',
    category: 'Agriculture',
    duration: '',
    location: '',
    features: '',
    image_path: '',
    image_url: '',
    is_active: true,
  })

  const serviceCategories = [
    'Agriculture',
    'Building', 
    'Energy',
    'Technology',
    'Transport',
    'Water Solutions',
    'Drilling',
    'Pumps'
  ]

  useEffect(() => {
    if (serviceId) {
      fetchService()
    }
  }, [serviceId])

  const fetchService = async () => {
    try {
      showInfo('Loading service...', 'Fetching service details')
      
      const { data, error } = await supabase
        .from('services')
        .select('*')
        .eq('id', serviceId)
        .single()

      if (error) throw error

      if (data) {
        setFormData({
          title: data.title || '',
          description: data.description || '',
          price: data.price?.toString() || '',
          category: data.category || 'Agriculture',
          duration: data.duration || '',
          location: data.location || '',
          features: data.features ? data.features.join(', ') : '',
          image_path: data.image_path || '',
          image_url: data.image_url || '',
          is_active: data.is_active ?? true,
        })
        showSuccess('Service loaded', 'Service details loaded successfully')
      }
    } catch (error) {
      console.error('Error fetching service:', error)
      showError('Failed to load service', 'Please try again or go back to services list')
    } finally {
      setInitialLoading(false)
    }
  }

  const handleImageUploaded = (imagePath: string, imageUrl: string) => {
    setFormData(prev => ({
      ...prev,
      image_path: imagePath,
      image_url: imageUrl
    }))
  }

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value, type } = e.target
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? (e.target as HTMLInputElement).checked : value
    }))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)

    try {
      // Validate required fields
      if (!formData.title.trim() || !formData.description.trim() || !formData.price) {
        showError('Validation Error', 'Please fill in all required fields')
        return
      }

      showInfo('Updating service...', 'Please wait while we save your changes')

      // Parse features from comma-separated string to array
      const featuresArray = formData.features
        .split(',')
        .map(f => f.trim())
        .filter(f => f.length > 0)

      const serviceData = {
        title: formData.title.trim(),
        description: formData.description.trim(),
        price: parseFloat(formData.price),
        category: formData.category,
        duration: formData.duration.trim() || null,
        location: formData.location.trim() || null,
        features: featuresArray,
        image_path: formData.image_path || null,
        image_url: formData.image_url || null,
        is_active: formData.is_active,
        updated_at: new Date().toISOString(),
      }

      const { error } = await supabase
        .from('services')
        .update(serviceData)
        .eq('id', serviceId)

      if (error) throw error

      showSuccess('Service updated successfully!', `${formData.title} has been updated`)
      
      // Redirect after a short delay to show the success message
      setTimeout(() => {
        router.push('/dashboard/services')
      }, 1500)
    } catch (error) {
      console.error('Error updating service:', error)
      showError('Failed to update service', 'Please check your input and try again')
    } finally {
      setLoading(false)
    }
  }

  if (initialLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center space-x-4">
        <button
          onClick={() => router.back()}
          className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
        >
          <ArrowLeftIcon className="h-5 w-5 text-gray-600" />
        </button>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Edit Service</h1>
          <p className="text-gray-600">Update service information</p>
        </div>
      </div>

      {/* Form */}
      <div className="bg-white shadow rounded-lg">
        <form onSubmit={handleSubmit} className="p-6 space-y-6">
          {/* Basic Information */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label htmlFor="title" className="block text-sm font-medium text-gray-700 mb-2">
                Service Title *
              </label>
              <input
                type="text"
                id="title"
                name="title"
                required
                value={formData.title}
                onChange={handleInputChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
                placeholder="e.g., Greenhouse Construction"
              />
            </div>

            <div>
              <label htmlFor="category" className="block text-sm font-medium text-gray-700 mb-2">
                Category *
              </label>
              <select
                id="category"
                name="category"
                required
                value={formData.category}
                onChange={handleInputChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
              >
                {serviceCategories.map(category => (
                  <option key={category} value={category}>{category}</option>
                ))}
              </select>
            </div>
          </div>

          <div>
            <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-2">
              Description *
            </label>
            <textarea
              id="description"
              name="description"
              required
              rows={4}
              value={formData.description}
              onChange={handleInputChange}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
              placeholder="Detailed description of the service..."
            />
          </div>

          {/* Pricing and Details */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label htmlFor="price" className="block text-sm font-medium text-gray-700 mb-2">
                Price (USD) *
              </label>
              <input
                type="number"
                id="price"
                name="price"
                required
                min="0"
                step="0.01"
                value={formData.price}
                onChange={handleInputChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
                placeholder="0.00"
              />
            </div>

            <div>
              <label htmlFor="duration" className="block text-sm font-medium text-gray-700 mb-2">
                Duration
              </label>
              <input
                type="text"
                id="duration"
                name="duration"
                value={formData.duration}
                onChange={handleInputChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
                placeholder="e.g., 2-4 weeks"
              />
            </div>

            <div>
              <label htmlFor="location" className="block text-sm font-medium text-gray-700 mb-2">
                Service Location
              </label>
              <input
                type="text"
                id="location"
                name="location"
                value={formData.location}
                onChange={handleInputChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
                placeholder="e.g., On-site, Farm, Office"
              />
            </div>
          </div>

          {/* Features */}
          <div>
            <label htmlFor="features" className="block text-sm font-medium text-gray-700 mb-2">
              Features
            </label>
            <input
              type="text"
              id="features"
              name="features"
              value={formData.features}
              onChange={handleInputChange}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
              placeholder="Feature 1, Feature 2, Feature 3 (comma-separated)"
            />
            <p className="text-sm text-gray-500 mt-1">
              Enter features separated by commas
            </p>
          </div>

          {/* Image Upload */}
          <ImageUpload
            onImageUploaded={handleImageUploaded}
            currentImageUrl={formData.image_url}
            maxSizeInMB={5}
            className="w-full"
          />

          {/* Status */}
          <div className="flex items-center">
            <input
              type="checkbox"
              id="is_active"
              name="is_active"
              checked={formData.is_active}
              onChange={handleInputChange}
              className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
            />
            <label htmlFor="is_active" className="ml-2 block text-sm text-gray-700">
              Service is active and available for booking
            </label>
          </div>

          {/* Submit Buttons */}
          <div className="flex justify-end space-x-3 pt-6 border-t border-gray-200">
            <button
              type="button"
              onClick={() => router.back()}
              className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={loading}
              className="px-4 py-2 border border-transparent rounded-md text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? 'Updating...' : 'Update Service'}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}