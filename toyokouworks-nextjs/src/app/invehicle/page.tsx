'use client'
import { Select, SelectItem, Chip } from '@nextui-org/react'
import { Data, Race } from '@prisma/client'
import { Card, Title, AreaChart } from '@tremor/react'
import { useEffect, useState } from 'react'

import { useData } from '@/hooks/useData'

const dataFormatter = (number: number) => {
  return Intl.NumberFormat('us').format(number).toString()
}

export default function Home() {
  const [data, setData] = useState<
    {
      current: number
      voltage: number
      createdAt: Date
    }[]
  >([])
  const [lastData, setLastData] = useState<Data>()
  const [raceIds, setRaceIds] = useState<
    {
      name: string
      createdAt: Date
    }[]
  >([])
  const [selected, setSelected] = useState<string>('')
  const { getData, getRaceIds } = useData()
  useEffect(() => {
    const fetchRaceIds = async () => {
      const raceIds = await getRaceIds()
      setRaceIds(
        raceIds as Race[],
      )
    }
    fetchRaceIds()
  }, [])
  // 1秒に1回データを取得する
  useEffect(() => {
    const interval = setInterval(() => {
      const fetchData = async () => {
        const data = (await getData(selected)) as Data[]
        setData(data)
        setLastData(data[data.length - 1])
      }
      fetchData()
    }, 1000)
    return () => clearInterval(interval)
  })

  const handleSlectionChange = async (e: React.ChangeEvent<HTMLSelectElement>) => {
    setSelected(e.target.value)
  }

  // 小数点第n位までを四捨五入する
    const n = 2

  return (
    <>
      <div className='m-6 mb-0 flex flex-col sm:flex-row'>
        <div className="flex gap-4 items-center w-full">
            <Select
            label='Select Race ID'
            className='max-w-xs'
            value={selected}
            onChange={handleSlectionChange}
            >
            {raceIds.map((raceId) => (
                <SelectItem key={raceId.name} value={raceId.name}>
                {raceId.name}
                </SelectItem>
            ))}
            </Select>
            <Chip
                color='danger'
            >
                disconnected
            </Chip>
        </div>
        <div className="bg-blue-500 p-3 px-6 mt-3 max-w-sm md:max-w-[15rem] text-white rounded-2xl w-full">
            <h4 className='text-xs'>Battery</h4>
            <h2 className='text-2xl'>{lastData?.integratedCurrent ? Math.floor((((3600 - lastData.integratedCurrent) / 3600) * 100) * Math.pow( 10, n )) / Math.pow( 10, n ) : 0.00} %</h2>
        </div>
      </div>
      <div className='grid grid-cols-1 md:grid-cols-3 gap-4 items-center justify-center p-6'>
        <Card>
          <div className='flex justify-between'>
            <Title>Current</Title>
            <Title>{lastData?.current ? Math.floor( lastData?.current * Math.pow( 10, n ) ) / Math.pow( 10, n ) : 0} mA</Title>
          </div>
        </Card>
        <Card>
          <div className='flex justify-between'>
            <Title>Voltage</Title>
            <Title>{lastData?.voltage ? Math.floor( lastData?.voltage / 1000 * Math.pow( 10, n ) ) / Math.pow( 10, n ) : 0} V</Title>
          </div>
        </Card>
        <Card>
          <div className='flex justify-between'>
            <Title>Power</Title>
            <Title>{lastData?.current && lastData?.voltage ? Math.floor((lastData.current * lastData.voltage) / 1000 * Math.pow( 10, n )) / Math.pow( 10, n ) : 0} mW</Title>
          </div>
        </Card>
        <Card>
          <div className='flex justify-between'>
            <Title>Integrated</Title>
            <Title>{lastData?.integratedCurrent ? Math.floor((lastData.integratedCurrent) * Math.pow( 10, n )) / Math.pow( 10, n ) : 0.00} mAh</Title>
          </div>
        </Card>
        <Card>
          <div className='flex justify-between'>
            <Title>Speed(G)</Title>
            <Title>{lastData?.gpsSpeed ? Math.floor((lastData.gpsSpeed) * Math.pow( 10, n )) / Math.pow( 10, n ) : 0.00} km/h</Title>
          </div>
        </Card>
        <Card>
          <div className='flex justify-between'>
            <Title>Speed(H)</Title>
            <Title>{lastData?.hallSpeed ? Math.floor((lastData.hallSpeed) * Math.pow( 10, n )) / Math.pow( 10, n ) : 0.00} km/h</Title>
          </div>
        </Card>
      </div>
    </>
  )
}
