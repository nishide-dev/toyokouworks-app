'use client'
import { Select, SelectItem, Chip } from '@nextui-org/react'
import { Data, Race } from '@prisma/client'
import { GoogleMap, Marker, LoadScript } from '@react-google-maps/api';
import { Card, Title, AreaChart } from '@tremor/react'
import React, { useEffect, useState } from 'react'

import { useData } from '@/hooks/useData'

const dataFormatter = (number: number) => {
  return Intl.NumberFormat('us').format(number).toString()
}

const Map = ({ lat, lng }: {
  lat: number | null
  lng: number | null
}) => {
  // Google Mapsの初期設定
  const mapContainerStyle = {
    width: '100%',
    height: '30rem',
  };

  const center = {
    lat: lat || 0, // latが渡されない場合は0を使用
    lng: lng || 0, // lngが渡されない場合は0を使用
  };

  return (
    <LoadScript
    googleMapsApiKey={process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY as string}
  >
    <GoogleMap
      mapContainerStyle={mapContainerStyle}
      zoom={16}
      center={center}
    >
      {lat && lng && <Marker position={center} />}
    </GoogleMap>
  </LoadScript>
  );
};


export default function Home() {
  const [data, setData] = useState<Data[]>([])
  const [lastData, setLastData] = useState<Data>()
  const [connected, setConnected] = useState<boolean>(false)
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
        const raceIds = await getRaceIds()
        const newData = data.map((d) => {
          return {
            ...d,
            power: Math.floor((d.current * d.voltage) / 1000 * Math.pow( 10, n )) / Math.pow( 10, n ),
          }
        })
        setData(newData)
        setRaceIds(
          raceIds as Race[],
        )
        // setData(data)
        const lastData = data[data.length - 1]
        const lastDate = lastData ? new Date(lastData.createdAt) : new Date()
        const now = new Date()
        const diff = now.getTime() - lastDate.getTime()
        if (diff > 10000) {
          setConnected(false)
        } else if (diff == 0) {
          setConnected(false)
        } else {
          setConnected(true)
        }
        setLastData(lastData)
      }
      fetchData()
    }, 1000)
    return () => clearInterval(interval)
  }, [selected])

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
            showScrollIndicators={true}
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
                color={connected ? 'primary' : 'danger'}
            >
                {connected ? 'Connected' : 'Disconnected'}
            </Chip>
        </div>
        <div className="bg-blue-500 p-3 px-6 mt-3 max-w-sm md:max-w-[15rem] text-white rounded-2xl w-full">
            <h4 className='text-xs'>Battery</h4>
            <h2 className='text-2xl'>{lastData?.integratedCurrent ? Math.floor((((3600 - lastData.integratedCurrent) / 3600) * 100) * Math.pow( 10, n )) / Math.pow( 10, n ) : 0.00} %</h2>
        </div>
      </div>
      <div className='grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 items-center justify-center p-6'>
        <Card>
          <div className='flex justify-between'>
            <Title>Current</Title>
            <Title>{lastData?.current ? Math.floor( lastData?.current * Math.pow( 10, n ) ) / Math.pow( 10, n ) : 0} mA</Title>
          </div>
          <AreaChart
            className='h-72 mt-4'
            data={data}
            index='createdAt'
            categories={['current']}
            colors={['cyan']}
            valueFormatter={dataFormatter}
          />
        </Card>
        <Card>
          <div className='flex justify-between'>
            <Title>Voltage</Title>
            <Title>{lastData?.voltage ? Math.floor( lastData?.voltage / 1000 * Math.pow( 10, n ) ) / Math.pow( 10, n ) : 0} V</Title>
          </div>
          <AreaChart
            className='h-72 mt-4'
            data={data}
            index='createdAt'
            categories={['voltage']}
            colors={['teal']}
            valueFormatter={dataFormatter}
          />
        </Card>
        <Card>
          <div className='flex justify-between'>
            <Title>Power</Title>
            <Title>{lastData?.current && lastData?.voltage ? Math.floor((lastData.current * lastData.voltage) / 1000 * Math.pow( 10, n )) / Math.pow( 10, n ) : 0} mW</Title>
          </div>
          <AreaChart
            className='h-72 mt-4'
            data={data}
            index='createdAt'
            categories={['power']}
            colors={['indigo']}
            valueFormatter={dataFormatter}
          />
        </Card>
        <Card>
          <div className='flex justify-between'>
            <Title>Speed(G)</Title>
            <Title>{lastData?.gpsSpeed ? Math.floor((lastData.gpsSpeed) * Math.pow( 10, n )) / Math.pow( 10, n ) : 0.00} km/h</Title>
          </div>
          <AreaChart
            className='h-72 mt-4'
            data={data}
            index='createdAt'
            categories={['gpsSpeed']}
            colors={['orange']}
            valueFormatter={dataFormatter}
          />
        </Card>
      </div>
      <Card className='m-6'>
          <div className='flex flex-col gap-4 justify-between'>
            <Title>Google Map</Title>
            <Map lat={lastData?.lat ?? 0} lng={lastData?.lng ?? 0} /> {/* Google Mapコンポーネントを表示 */}
          </div>
        </Card>
    </>
  )
}
