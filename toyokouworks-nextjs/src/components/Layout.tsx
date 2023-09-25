'use client'
import { NextUIProvider } from '@nextui-org/react'
import { ThemeProvider as NextThemesProvider } from 'next-themes'
import React from 'react'

import Header from './Header'

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <body>
      <NextUIProvider>
        <NextThemesProvider attribute='class' defaultTheme='dark'>
          <main>
            <Header />
            {children}
          </main>
        </NextThemesProvider>
      </NextUIProvider>
    </body>
  )
}
