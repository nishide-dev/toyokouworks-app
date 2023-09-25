'use client'
import Image from 'next/image'
import React from 'react'

export const TWLogo: React.FC = () => (
  <Image src='/tw-logo.png' alt='TOYOKOUWORKS' className='dark:invert' width={64} height={64} />
)
