import { NextResponse } from 'next/server'

import prisma from '@/lib/prisma'

export const GET = async (request: Request) => {
  const data = await prisma.race.findMany({
    select: {
      name: true,
      createdAt: true,
    },
  })

  return NextResponse.json(data)
}
