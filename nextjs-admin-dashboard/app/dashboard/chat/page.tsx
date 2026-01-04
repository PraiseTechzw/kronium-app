'use client'

import { useEffect, useState } from 'react'
import { useSupabase } from '../../providers'
import {
  ChatBubbleLeftRightIcon,
  PaperAirplaneIcon,
  UserIcon,
  ClockIcon,
} from '@heroicons/react/24/outline'

interface ChatMessage {
  id: string
  user_id: string
  message: string
  is_admin: boolean
  created_at: string
  users?: {
    name: string
    email: string
  }
}

interface ChatSession {
  user_id: string
  user_name: string
  user_email: string
  last_message: string
  last_message_time: string
  unread_count: number
}

export default function ChatPage() {
  const { supabase, user } = useSupabase()
  const [chatSessions, setChatSessions] = useState<ChatSession[]>([])
  const [selectedSession, setSelectedSession] = useState<string | null>(null)
  const [messages, setMessages] = useState<ChatMessage[]>([])
  const [newMessage, setNewMessage] = useState('')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchChatSessions()
  }, [])

  useEffect(() => {
    if (selectedSession) {
      fetchMessages(selectedSession)
    }
  }, [selectedSession])

  const fetchChatSessions = async () => {
    try {
      // This is a simplified version - in a real app, you'd have a proper chat system
      // For now, we'll simulate chat sessions based on users who have bookings
      const { data: users, error } = await supabase
        .from('users')
        .select(`
          id,
          name,
          email,
          bookings(created_at)
        `)
        .eq('role', 'customer')
        .not('bookings', 'is', null)

      if (error) throw error

      const sessions: ChatSession[] = users?.map(user => ({
        user_id: user.id,
        user_name: user.name,
        user_email: user.email,
        last_message: 'No messages yet',
        last_message_time: new Date().toISOString(),
        unread_count: 0,
      })) || []

      setChatSessions(sessions)
    } catch (error) {
      console.error('Error fetching chat sessions:', error)
    } finally {
      setLoading(false)
    }
  }

  const fetchMessages = async (userId: string) => {
    try {
      // Simulate fetching messages - in a real app, you'd have a messages table
      const mockMessages: ChatMessage[] = [
        {
          id: '1',
          user_id: userId,
          message: 'Hello, I have a question about my booking.',
          is_admin: false,
          created_at: new Date(Date.now() - 3600000).toISOString(),
        },
        {
          id: '2',
          user_id: 'admin',
          message: 'Hi! I\'d be happy to help you with your booking. What can I assist you with?',
          is_admin: true,
          created_at: new Date(Date.now() - 3000000).toISOString(),
        },
        {
          id: '3',
          user_id: userId,
          message: 'I need to reschedule my appointment for next week.',
          is_admin: false,
          created_at: new Date(Date.now() - 1800000).toISOString(),
        },
      ]

      setMessages(mockMessages)
    } catch (error) {
      console.error('Error fetching messages:', error)
    }
  }

  const sendMessage = async () => {
    if (!newMessage.trim() || !selectedSession) return

    try {
      const message: ChatMessage = {
        id: Date.now().toString(),
        user_id: 'admin',
        message: newMessage,
        is_admin: true,
        created_at: new Date().toISOString(),
      }

      setMessages(prev => [...prev, message])
      setNewMessage('')

      // In a real app, you'd save this to the database
      // await supabase.from('messages').insert([message])
    } catch (error) {
      console.error('Error sending message:', error)
    }
  }

  const formatTime = (timestamp: string) => {
    return new Date(timestamp).toLocaleTimeString([], { 
      hour: '2-digit', 
      minute: '2-digit' 
    })
  }

  const formatDate = (timestamp: string) => {
    const date = new Date(timestamp)
    const today = new Date()
    const yesterday = new Date(today)
    yesterday.setDate(yesterday.getDate() - 1)

    if (date.toDateString() === today.toDateString()) {
      return 'Today'
    } else if (date.toDateString() === yesterday.toDateString()) {
      return 'Yesterday'
    } else {
      return date.toLocaleDateString()
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  return (
    <div className="h-[calc(100vh-8rem)] flex">
      {/* Chat Sessions Sidebar */}
      <div className="w-1/3 bg-white border-r border-gray-200 flex flex-col">
        <div className="p-4 border-b border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900">Customer Chats</h2>
          <p className="text-sm text-gray-600">Manage customer support conversations</p>
        </div>
        
        <div className="flex-1 overflow-y-auto">
          {chatSessions.length > 0 ? (
            chatSessions.map((session) => (
              <div
                key={session.user_id}
                onClick={() => setSelectedSession(session.user_id)}
                className={`p-4 border-b border-gray-100 cursor-pointer hover:bg-gray-50 ${
                  selectedSession === session.user_id ? 'bg-primary-50 border-primary-200' : ''
                }`}
              >
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center">
                    <div className="h-10 w-10 bg-primary-600 rounded-full flex items-center justify-center">
                      <span className="text-sm font-medium text-white">
                        {session.user_name?.charAt(0).toUpperCase()}
                      </span>
                    </div>
                    <div className="ml-3">
                      <p className="text-sm font-medium text-gray-900">{session.user_name}</p>
                      <p className="text-xs text-gray-500">{session.user_email}</p>
                    </div>
                  </div>
                  {session.unread_count > 0 && (
                    <span className="bg-primary-600 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">
                      {session.unread_count}
                    </span>
                  )}
                </div>
                <p className="text-sm text-gray-600 truncate">{session.last_message}</p>
                <div className="flex items-center mt-1">
                  <ClockIcon className="h-3 w-3 text-gray-400 mr-1" />
                  <span className="text-xs text-gray-500">
                    {formatDate(session.last_message_time)}
                  </span>
                </div>
              </div>
            ))
          ) : (
            <div className="p-8 text-center">
              <ChatBubbleLeftRightIcon className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">No active chats</h3>
              <p className="mt-1 text-sm text-gray-500">
                Customer conversations will appear here
              </p>
            </div>
          )}
        </div>
      </div>

      {/* Chat Messages Area */}
      <div className="flex-1 flex flex-col">
        {selectedSession ? (
          <>
            {/* Chat Header */}
            <div className="p-4 border-b border-gray-200 bg-white">
              <div className="flex items-center">
                <div className="h-8 w-8 bg-primary-600 rounded-full flex items-center justify-center">
                  <span className="text-sm font-medium text-white">
                    {chatSessions.find(s => s.user_id === selectedSession)?.user_name?.charAt(0).toUpperCase()}
                  </span>
                </div>
                <div className="ml-3">
                  <p className="text-sm font-medium text-gray-900">
                    {chatSessions.find(s => s.user_id === selectedSession)?.user_name}
                  </p>
                  <p className="text-xs text-gray-500">
                    {chatSessions.find(s => s.user_id === selectedSession)?.user_email}
                  </p>
                </div>
              </div>
            </div>

            {/* Messages */}
            <div className="flex-1 overflow-y-auto p-4 space-y-4 bg-gray-50">
              {messages.map((message) => (
                <div
                  key={message.id}
                  className={`flex ${message.is_admin ? 'justify-end' : 'justify-start'}`}
                >
                  <div
                    className={`max-w-xs lg:max-w-md px-4 py-2 rounded-lg ${
                      message.is_admin
                        ? 'bg-primary-600 text-white'
                        : 'bg-white text-gray-900 border border-gray-200'
                    }`}
                  >
                    <p className="text-sm">{message.message}</p>
                    <p className={`text-xs mt-1 ${
                      message.is_admin ? 'text-primary-100' : 'text-gray-500'
                    }`}>
                      {formatTime(message.created_at)}
                    </p>
                  </div>
                </div>
              ))}
            </div>

            {/* Message Input */}
            <div className="p-4 border-t border-gray-200 bg-white">
              <div className="flex space-x-2">
                <input
                  type="text"
                  value={newMessage}
                  onChange={(e) => setNewMessage(e.target.value)}
                  onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
                  placeholder="Type your message..."
                  className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                />
                <button
                  onClick={sendMessage}
                  disabled={!newMessage.trim()}
                  className="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary-500 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <PaperAirplaneIcon className="h-4 w-4" />
                </button>
              </div>
            </div>
          </>
        ) : (
          <div className="flex-1 flex items-center justify-center bg-gray-50">
            <div className="text-center">
              <ChatBubbleLeftRightIcon className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">Select a conversation</h3>
              <p className="mt-1 text-sm text-gray-500">
                Choose a customer from the sidebar to start chatting
              </p>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}