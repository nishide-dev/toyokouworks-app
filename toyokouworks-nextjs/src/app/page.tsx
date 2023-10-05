'use client';
import { Data } from "@prisma/client";
import { Card, Title, AreaChart } from "@tremor/react";
import Image from 'next/image'
import { useEffect, useState } from "react";

import { useData } from "@/hooks/useData";

const dataFormatter = (number: number) => {
  return Intl.NumberFormat("us").format(number).toString();
};

export default function Home() {
  const [data, setData] = useState<{
    current: number;
    voltage: number;
    createdAt: Date;
  }[]>([]);
  const [lastData, setLastData] = useState<{
    current: number;
    voltage: number;
    createdAt: Date;
  }>();
  const { getData } = useData();
  // 2秒に1回データを取得する
  useEffect(() => {
    const interval = setInterval(() => {
      const fetchData = async () => {
        const data = await getData('test') as {
          current: number;
          voltage: number;
          createdAt: Date;
        }[];
        setData(data);
        setLastData(data[data.length - 1]);
      }
      fetchData();
    }, 2000);
    return () => clearInterval(interval);
  });

  return (
    <>
      <div className='flex flex-col md:flex-row gap-6 h-screen items-center justify-center p-6'>
      <Card>
        <div className="flex justify-between">
          <Title>Current (mA)</Title>
          <Title>{lastData?.current} mA</Title>
        </div>
        <AreaChart
          className="h-72 mt-4"
          data={data}
          index="createdAt"
          categories={["current"]}
          colors={["indigo"]}
          valueFormatter={dataFormatter}
        />
      </Card>
      <Card>
        <div className="flex justify-between">
          <Title>Voltage (mV)</Title>
          <Title>{lastData?.voltage} mV</Title>
        </div>
        <AreaChart
          className="h-72 mt-4"
          data={data}
          index="createdAt"
          categories={["voltage"]}
          colors={["cyan"]}
          valueFormatter={dataFormatter}
        />
      </Card>
    </div>
    </>
  )

}
