'use client'
import { useSwitch, VisuallyHidden, SwitchProps } from '@nextui-org/react'
import { useTheme } from 'next-themes'
import React from 'react'

import { MoonIcon } from './icons/MoonIcon'
import { SunIcon } from './icons/SunIcon'

const ThemeSwitch = (props: SwitchProps) => {
  const { Component, slots, isSelected, getBaseProps, getInputProps, getWrapperProps } =
    useSwitch(props)

  const { theme, setTheme } = useTheme()

  return (
    <div className='flex flex-col gap-2 md:pr-4'>
      <Component {...getBaseProps()}>
        <VisuallyHidden>
          <input {...getInputProps()} />
        </VisuallyHidden>
        <div
          {...getWrapperProps()}
          onClick={() => {
            isSelected ? setTheme('dark') : setTheme('light')
          }}
          color='primary'
          className={slots.wrapper({
            class: [
              'w-8 h-8',
              'flex items-center justify-center',
              'rounded-lg bg-default-100 hover:bg-default-200',
            ],
          })}
        >
          {isSelected ? <SunIcon /> : <MoonIcon />}
        </div>
      </Component>
    </div>
  )
}

export default function ThemeSwitcher() {
  return <ThemeSwitch />
}
