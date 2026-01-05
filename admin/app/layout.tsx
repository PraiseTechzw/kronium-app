import './globals.css'
import { Inter } from 'next/font/google'
import { Providers } from './providers'
import { ToastProvider } from '../components/ToastContainer'

const inter = Inter({ subsets: ['latin'] })

export const metadata = {
  title: 'Kronium Admin Dashboard',
  description: 'Administrative dashboard for Kronium agricultural and construction services platform',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <Providers>
          <ToastProvider>
            {children}
          </ToastProvider>
        </Providers>
      </body>
    </html>
  )
}