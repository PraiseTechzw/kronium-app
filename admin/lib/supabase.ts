import { createClientComponentClient, createServerComponentClient } from '@supabase/auth-helpers-nextjs'
import { cookies } from 'next/headers'

export const createClient = () => createClientComponentClient()

export const createServerClient = () => createServerComponentClient({ cookies })

export type Database = {
  public: {
    Tables: {
      users: {
        Row: {
          id: string
          simple_id: string | null
          name: string
          email: string
          phone: string
          profile_image: string | null
          address: string | null
          created_at: string
          updated_at: string
          is_active: boolean
          favorite_services: string[]
          role: string
        }
        Insert: {
          id: string
          simple_id?: string | null
          name: string
          email: string
          phone: string
          profile_image?: string | null
          address?: string | null
          created_at?: string
          updated_at?: string
          is_active?: boolean
          favorite_services?: string[]
          role?: string
        }
        Update: {
          id?: string
          simple_id?: string | null
          name?: string
          email?: string
          phone?: string
          profile_image?: string | null
          address?: string | null
          created_at?: string
          updated_at?: string
          is_active?: boolean
          favorite_services?: string[]
          role?: string
        }
      }
      services: {
        Row: {
          id: string
          title: string
          description: string
          price: number
          category: string
          image_url: string | null
          is_active: boolean
          created_at: string
          updated_at: string
          features: string[]
          duration: string | null
          location: string | null
        }
        Insert: {
          id?: string
          title: string
          description: string
          price: number
          category: string
          image_url?: string | null
          is_active?: boolean
          created_at?: string
          updated_at?: string
          features?: string[]
          duration?: string | null
          location?: string | null
        }
        Update: {
          id?: string
          title?: string
          description?: string
          price?: number
          category?: string
          image_url?: string | null
          is_active?: boolean
          created_at?: string
          updated_at?: string
          features?: string[]
          duration?: string | null
          location?: string | null
        }
      }
      bookings: {
        Row: {
          id: string
          user_id: string
          service_id: string
          status: string
          booking_date: string
          notes: string | null
          created_at: string
          updated_at: string
          total_amount: number | null
        }
        Insert: {
          id?: string
          user_id: string
          service_id: string
          status?: string
          booking_date: string
          notes?: string | null
          created_at?: string
          updated_at?: string
          total_amount?: number | null
        }
        Update: {
          id?: string
          user_id?: string
          service_id?: string
          status?: string
          booking_date?: string
          notes?: string | null
          created_at?: string
          updated_at?: string
          total_amount?: number | null
        }
      }
      projects: {
        Row: {
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
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          title: string
          description: string
          status?: string
          location: string
          budget?: number | null
          start_date?: string | null
          end_date?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          title?: string
          description?: string
          status?: string
          location?: string
          budget?: number | null
          start_date?: string | null
          end_date?: string | null
          created_at?: string
          updated_at?: string
        }
      }
    }
  }
}