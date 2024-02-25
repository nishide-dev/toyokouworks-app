import { PrismaClient } from "@prisma/client";
import AWS from "aws-sdk";
AWS.config.update({ region: "ap-northeast-1" });
AWS.config.apiVersions = {
    s3: "2006-03-01",
};

/*
event: {
}
*/

const prisma = new PrismaClient();

export async function handler(event: any): Promise<any> {
    const randomString = Math.random().toString(32).substring(2);

    try {
        const { race, current, voltage, integratedCurrent, gpsSpeed, lat, lng, hallSpeed } = event as {
            race: string;
            current: number;
            voltage: number;
            integratedCurrent: number;
            gpsSpeed?: number;
            lat?: number;
            lng?: number;
            hallSpeed?: number;
        };

        // 最後のデータを取得する
        const lastData = await prisma.data.findFirst({
            orderBy: {
                createdAt: "desc",
            },
        });

        // 積算電流を計算する
        // const integratedCurrent = lastData?.integratedCurrent ?? 0;
        // const lastTime = lastData?.createdAt ?? new Date();
        // const currentTime = new Date();
        // const timeDiff = currentTime.getTime() - lastTime.getTime();
        // const integratedCurrentDiff = current * timeDiff;
        // const integratedCurrentTotal = lastData ? integratedCurrent + integratedCurrentDiff : 0;

        // raceIdが存在しない場合は作成する
        const searchedRaceId = await prisma.race.findUnique({
            where: {
                id: race,
            },
        });

        if (!searchedRaceId) {
            await prisma.race.create({
                data: {
                    id: race,
                    name: race,
                },
            });
        }

        // データを作成する
        await prisma.data.create({
            data: {
                raceId: race,
                current,
                voltage,
                integratedCurrent,
                gpsSpeed,
                lat,
                lng,
                hallSpeed,
            },
        });

        return {
            statusCode: 200,
            body: {
                race,
                current,
                voltage,
                integratedCurrent,
                gpsSpeed,
                lat,
                lng,
                hallSpeed,
            }
        }
    } catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify(error)
        }
    }
}
