'use client'

import { useEffect, useState } from 'react'
import { useSupabase } from '../../providers'
import {
  MagnifyingGlassIcon,
  CogIcon,
  EyeIcon,
  PencilIcon,
  TrashIcon,
} from '@heroicons/react/24/outline'

interface Project {
  id: string
  user_id: string
  title: string
  description: string
  status: string
  location: string
  budget: number | null
  start_date: string | null
  end_date: string | null
  created_at: string
  users: {
    name: string
    email: string
    phone: string
  } | null
}

export default function ProjectsPage() {
  const { supabase } = useSupabase()
  const [projects, setProjects] = useState<Project[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')
  const [selectedProject, setSelectedProject] = useState<Project | null>(null)

  useEffect(() => {
    fetchProjects()
  }, [])

  const fetchProjects = async () => {
    try {
      const { data, error } = await supabase
        .from('projects')
        .select(`
          *,
          users(name, email, phone)
        `)
        .order('created_at', { ascending: false })

      if (error) throw error
      setProjects(data || [])
    } catch (error) {
      console.error('Error fetching projects:', error)
    } finally {
      setLoading(false)
    }
  }

  const updateProjectStatus = async (projectId: string, newStatus: string) => {
    try {
      const { error } = await supabase
        .from('projects')
        .update({ status: newStatus })
        .eq('id', projectId)

      if (error) throw error
      
      setProjects(projects.map(project => 
        project.id === projectId ? { ...project, status: newStatus } : project
      ))
      
      alert(`Project status updated to ${newStatus}`)
    } catch (error) {
      console.error('Error updating project status:', error)
      alert('Error updating project status')
    }
  }

  const deleteProject = async (projectId: string) => {
    if (!confirm('Are you sure you want to delete this project?')) return

    try {
      const { error } = await supabase
        .from('projects')
        .delete()
        .eq('id', projectId)

      if (error) throw error
      
      setProjects(projects.filter(project => project.id !== projectId))
      alert('Project deleted successfully')
    } catch (error) {
      console.error('Error deleting project:', error)
      alert('Error deleting project')
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active':
        return 'bg-green-100 text-green-800'
      case 'pending':
        return 'bg-yellow-100 text-yellow-800'
      case 'completed':
        return 'bg-blue-100 text-blue-800'
      case 'cancelled':
        return 'bg-red-100 text-red-800'
      case 'on-hold':
        return 'bg-gray-100 text-gray-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  const filteredProjects = projects.filter(project => {
    const matchesSearch = 
      project.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      project.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
      project.users?.name.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = statusFilter === 'all' || project.status === statusFilter
    return matchesSearch && matchesStatus
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
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Projects Management</h1>
        <p className="text-gray-600">Manage all customer projects and their progress</p>
      </div>

      {/* Filters */}
      <div className="bg-white p-4 rounded-lg shadow">
        <div className="flex flex-col sm:flex-row gap-4">
          <div className="flex-1">
            <div className="relative">
              <MagnifyingGlassIcon className="h-5 w-5 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                placeholder="Search projects..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
              />
            </div>
          </div>
          <div>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-md focus:ring-primary-500 focus:border-primary-500"
            >
              <option value="all">All Status</option>
              <option value="pending">Pending</option>
              <option value="active">Active</option>
              <option value="on-hold">On Hold</option>
              <option value="completed">Completed</option>
              <option value="cancelled">Cancelled</option>
            </select>
          </div>
        </div>
      </div>

      {/* Projects Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredProjects.map((project) => (
          <div key={project.id} className="bg-white rounded-lg shadow hover:shadow-md transition-shadow">
            <div className="p-6">
              {/* Project Header */}
              <div className="flex justify-between items-start mb-4">
                <h3 className="text-lg font-semibold text-gray-900 truncate">{project.title}</h3>
                <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(project.status)}`}>
                  {project.status}
                </span>
              </div>

              {/* Customer Info */}
              <div className="mb-4">
                <p className="text-sm font-medium text-gray-700">Customer:</p>
                <p className="text-sm text-gray-900">{project.users?.name || 'Unknown'}</p>
                <p className="text-sm text-gray-500">{project.users?.email}</p>
              </div>

              {/* Project Details */}
              <div className="space-y-2 mb-4">
                <p className="text-sm text-gray-600 line-clamp-3">{project.description}</p>
                
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-500">Location:</span>
                  <span className="text-sm text-gray-900">{project.location}</span>
                </div>

                {project.budget && (
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-gray-500">Budget:</span>
                    <span className="text-sm font-medium text-green-600">${project.budget}</span>
                  </div>
                )}

                {project.start_date && (
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-gray-500">Start Date:</span>
                    <span className="text-sm text-gray-900">
                      {new Date(project.start_date).toLocaleDateString()}
                    </span>
                  </div>
                )}

                {project.end_date && (
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-gray-500">End Date:</span>
                    <span className="text-sm text-gray-900">
                      {new Date(project.end_date).toLocaleDateString()}
                    </span>
                  </div>
                )}
              </div>

              {/* Status Update Buttons */}
              <div className="mb-4">
                <p className="text-sm text-gray-500 mb-2">Update Status:</p>
                <div className="flex flex-wrap gap-1">
                  {['pending', 'active', 'on-hold', 'completed', 'cancelled'].map((status) => (
                    <button
                      key={status}
                      onClick={() => updateProjectStatus(project.id, status)}
                      disabled={project.status === status}
                      className={`px-2 py-1 text-xs rounded ${
                        project.status === status
                          ? 'bg-gray-200 text-gray-500 cursor-not-allowed'
                          : 'bg-primary-100 text-primary-700 hover:bg-primary-200'
                      }`}
                    >
                      {status}
                    </button>
                  ))}
                </div>
              </div>

              {/* Actions */}
              <div className="flex justify-between items-center pt-4 border-t border-gray-200">
                <span className="text-xs text-gray-500">
                  Created {new Date(project.created_at).toLocaleDateString()}
                </span>
                <div className="flex space-x-2">
                  <button
                    onClick={() => setSelectedProject(project)}
                    className="text-primary-600 hover:text-primary-900 p-1"
                    title="View Details"
                  >
                    <EyeIcon className="h-4 w-4" />
                  </button>
                  <button
                    onClick={() => deleteProject(project.id)}
                    className="text-red-600 hover:text-red-900 p-1"
                    title="Delete Project"
                  >
                    <TrashIcon className="h-4 w-4" />
                  </button>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {filteredProjects.length === 0 && (
        <div className="text-center py-12">
          <CogIcon className="mx-auto h-12 w-12 text-gray-400" />
          <h3 className="mt-2 text-sm font-medium text-gray-900">No projects found</h3>
          <p className="mt-1 text-sm text-gray-500">
            {searchTerm || statusFilter !== 'all' 
              ? 'Try adjusting your search or filter criteria.'
              : 'No projects have been created yet.'
            }
          </p>
        </div>
      )}

      {/* Project Details Modal */}
      {selectedProject && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white max-h-96 overflow-y-auto">
            <div className="mt-3">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-medium text-gray-900">Project Details</h3>
                <button
                  onClick={() => setSelectedProject(null)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  ×
                </button>
              </div>
              
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">Title</label>
                  <p className="text-sm text-gray-900">{selectedProject.title}</p>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">Description</label>
                  <p className="text-sm text-gray-900">{selectedProject.description}</p>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">Customer</label>
                  <p className="text-sm text-gray-900">{selectedProject.users?.name}</p>
                  <p className="text-sm text-gray-500">{selectedProject.users?.email}</p>
                  <p className="text-sm text-gray-500">{selectedProject.users?.phone}</p>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">Location</label>
                  <p className="text-sm text-gray-900">{selectedProject.location}</p>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">Status</label>
                  <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(selectedProject.status)}`}>
                    {selectedProject.status}
                  </span>
                </div>
                
                {selectedProject.budget && (
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Budget</label>
                    <p className="text-sm text-gray-900">${selectedProject.budget}</p>
                  </div>
                )}
                
                {selectedProject.start_date && (
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Start Date</label>
                    <p className="text-sm text-gray-900">
                      {new Date(selectedProject.start_date).toLocaleDateString()}
                    </p>
                  </div>
                )}
                
                {selectedProject.end_date && (
                  <div>
                    <label className="block text-sm font-medium text-gray-700">End Date</label>
                    <p className="text-sm text-gray-900">
                      {new Date(selectedProject.end_date).toLocaleDateString()}
                    </p>
                  </div>
                )}
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">Created</label>
                  <p className="text-sm text-gray-500">
                    {new Date(selectedProject.created_at).toLocaleString()}
                  </p>
                </div>
              </div>
              
              <div className="mt-6 flex justify-end">
                <button
                  onClick={() => setSelectedProject(null)}
                  className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50"
                >
                  Close
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}