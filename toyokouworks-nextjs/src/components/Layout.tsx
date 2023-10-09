'use client'
import { NextUIProvider } from '@nextui-org/react'
import { ThemeProvider as NextThemesProvider } from 'next-themes'
import React from 'react'

import Header from './Header'

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <body>
      <NextUIProvider>
        <NextThemesProvider attribute='class' defaultTheme='system' enableSystem>
          <main className='min-h-screen mx-auto max-w-7xl'>
            <Header />
            {children}
          </main>
        </NextThemesProvider>
      </NextUIProvider>
    </body>
  )
}
