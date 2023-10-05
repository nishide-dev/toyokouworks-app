'use client';
import { Select, SelectItem } from "@nextui-org/react";
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
  const [raceIds, setRaceIds] = useState<{
    name: string;
    createdAt: Date;
  }[]>([]);
  const [selected, setSelected] = useState<string>('test');
  const { getData, getRaceIds } = useData();
  useEffect(() => {
    const fetchRaceIds = async () => {
      const raceIds = await getRaceIds();
      setRaceIds(raceIds as {
        name: string;
        createdAt: Date;
      }[]);
    }
    fetchRaceIds();
  }, []);
  // 1秒に1回データを取得する
  useEffect(() => {
    const interval = setInterval(() => {
      const fetchData = async () => {
        const data = await getData(selected) as {
          current: number;
          voltage: number;
          createdAt: Date;
        }[];
        setData(data);
        setLastData(data[data.length - 1]);
      }
      fetchData();
    }, 1000);
    return () => clearInterval(interval);
  });

  const handleSlectionChange = async (
    e: React.ChangeEvent<HTMLSelectElement>,
  ) => {
    setSelected(e.target.value);
  };

  return (
    <>
      <div className="m-6">
      <Select 
        label="Select Race ID" 
        className="max-w-xs"
        value={selected}
        onChange={handleSlectionChange}
      >
        {raceIds.map((raceId) => (
          <SelectItem key={raceId.name} value={raceId.name}>
            {raceId.name}
          </SelectItem>
        ))}
      </Select>
      </div>
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
