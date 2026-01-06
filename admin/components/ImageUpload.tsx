'use client'

import { useState, useRef } from 'react'
import { useSupabase } from '../app/providers'
import { useToast } from './ToastContainer'
import {
  PhotoIcon,
  XMarkIcon,
  ArrowUpTrayIcon,
} from '@heroicons/react/24/outline'

interface ImageUploadProps {
  onImageUploaded: (imagePath: string, imageUrl: string) => void
  currentImageUrl?: string
  maxSizeInMB?: number
  acceptedTypes?: string[]
  className?: string
}

export function ImageUpload({
  onImageUploaded,
  currentImageUrl,
  maxSizeInMB = 5,
  acceptedTypes = ['image/jpeg', 'image/png', 'image/webp'],
  className = ''
}: ImageUploadProps) {
  const { supabase } = useSupabase()
  const { showSuccess, showError, showInfo } = useToast()
  const fileInputRef = useRef<HTMLInputElement>(null)
  const [uploading, setUploading] = useState(false)
  const [preview, setPreview] = useState<string | null>(currentImageUrl || null)
  const [dragOver, setDragOver] = useState(false)

  const validateFile = (file: File): string | null => {
    // Check file type
    if (!acceptedTypes.includes(file.type)) {
      return `File type not supported. Please use: ${acceptedTypes.join(', ')}`
    }

    // Check file size
    const maxSizeInBytes = maxSizeInMB * 1024 * 1024
    if (file.size > maxSizeInBytes) {
      return `File size too large. Maximum size is ${maxSizeInMB}MB`
    }

    return null
  }

  const uploadImage = async (file: File) => {
    const validationError = validateFile(file)
    if (validationError) {
      showError('Invalid file', validationError)
      return
    }

    setUploading(true)
    showInfo('Uploading image...', 'Please wait while we process your image')

    try {
      // Generate unique filename
      const fileExt = file.name.split('.').pop()
      const fileName = `${Date.now()}-${Math.random().toString(36).substring(2)}.${fileExt}`
      const filePath = `service-images/${fileName}`

      // Upload to Supabase Storage
      const { data, error } = await supabase.storage
        .from('service-images')
        .upload(filePath, file, {
          cacheControl: '3600',
          upsert: false
        })

      if (error) {
        console.error('Upload error:', error)
        throw error
      }

      // Get public URL
      const { data: { publicUrl } } = supabase.storage
        .from('service-images')
        .getPublicUrl(filePath)

      setPreview(publicUrl)
      onImageUploaded(filePath, publicUrl)
      showSuccess('Image uploaded successfully!', 'Your service image has been uploaded')
    } catch (error) {
      console.error('Error uploading image:', error)
      showError('Upload failed', 'Failed to upload image. Please try again.')
    } finally {
      setUploading(false)
    }
  }

  const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (file) {
      uploadImage(file)
    }
  }

  const handleDrop = (event: React.DragEvent) => {
    event.preventDefault()
    setDragOver(false)
    
    const file = event.dataTransfer.files[0]
    if (file) {
      uploadImage(file)
    }
  }

  const handleDragOver = (event: React.DragEvent) => {
    event.preventDefault()
    setDragOver(true)
  }

  const handleDragLeave = (event: React.DragEvent) => {
    event.preventDefault()
    setDragOver(false)
  }

  const removeImage = () => {
    setPreview(null)
    onImageUploaded('', '')
    if (fileInputRef.current) {
      fileInputRef.current.value = ''
    }
  }

  const openFileDialog = () => {
    fileInputRef.current?.click()
  }

  return (
    <div className={`space-y-4 ${className}`}>
      <label className="block text-sm font-medium text-gray-700">
        Service Image
      </label>
      
      {preview ? (
        <div className="relative">
          <div className="relative w-full h-48 bg-gray-100 rounded-lg overflow-hidden">
            <img
              src={preview}
              alt="Service preview"
              className="w-full h-full object-cover"
            />
            <div className="absolute inset-0 bg-black bg-opacity-0 hover:bg-opacity-20 transition-all duration-200 flex items-center justify-center">
              <button
                type="button"
                onClick={removeImage}
                className="opacity-0 hover:opacity-100 transition-opacity bg-red-600 text-white p-2 rounded-full hover:bg-red-700"
                title="Remove image"
              >
                <XMarkIcon className="h-5 w-5" />
              </button>
            </div>
          </div>
          <div className="mt-2 flex justify-between items-center">
            <span className="text-sm text-gray-600">Image uploaded successfully</span>
            <button
              type="button"
              onClick={openFileDialog}
              className="text-sm text-primary-600 hover:text-primary-700"
            >
              Change image
            </button>
          </div>
        </div>
      ) : (
        <div
          className={`relative border-2 border-dashed rounded-lg p-6 transition-colors ${
            dragOver
              ? 'border-primary-500 bg-primary-50'
              : 'border-gray-300 hover:border-gray-400'
          }`}
          onDrop={handleDrop}
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
        >
          <div className="text-center">
            {uploading ? (
              <div className="flex flex-col items-center">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mb-4"></div>
                <p className="text-sm text-gray-600">Uploading image...</p>
              </div>
            ) : (
              <>
                <PhotoIcon className="mx-auto h-12 w-12 text-gray-400" />
                <div className="mt-4">
                  <button
                    type="button"
                    onClick={openFileDialog}
                    className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-primary-700 bg-primary-100 hover:bg-primary-200"
                  >
                    <ArrowUpTrayIcon className="h-4 w-4 mr-2" />
                    Upload Image
                  </button>
                </div>
                <p className="mt-2 text-sm text-gray-600">
                  or drag and drop an image here
                </p>
                <p className="text-xs text-gray-500 mt-1">
                  PNG, JPG, WebP up to {maxSizeInMB}MB
                </p>
              </>
            )}
          </div>
        </div>
      )}

      <input
        ref={fileInputRef}
        type="file"
        accept={acceptedTypes.join(',')}
        onChange={handleFileSelect}
        className="hidden"
      />
    </div>
  )
}