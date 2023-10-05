import { NextResponse } from 'next/server';

import prisma from '@/lib/prisma';

export const POST = async (request: Request) => {

    const { raceId } = await request.json();

    const data = await prisma.data.findMany({
      where: {
        raceId: raceId,
      },
      select: {
        current: true,
        voltage: true,
        createdAt: true,
      }
    });

  return NextResponse.json(data);
};

export const GET = async (request: Request) => {

  const data = await prisma.data.findMany({
    where: {
      raceId: "test",
    },
    select: {
      current: true,
      voltage: true,
      createdAt: true,
    }
  });

return NextResponse.json(data);
};
