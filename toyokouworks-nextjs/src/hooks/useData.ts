'use client';
import { Data } from '@prisma/client';
import { useEffect, useState, useCallback } from 'react';

import fetchJson, { FetchError } from '@/lib/fetchJson';

export const useData = function () {
  const [gettingError, setGettingError] = useState<string>('');
  const [isGetting, setIsGetting] = useState<boolean>(false);

  const getData = async (
    raceId: string,
  ) => {
    setIsGetting(true);
    try {
      const response = (await fetchJson('/api/data', 'POST', {
        raceId: raceId,
      })) as Data[];
      setGettingError('');
      setIsGetting(false);
      return response;
    } catch (e: any) {
      if (e instanceof FetchError) {
        setGettingError(e.data.message);
      } else {
        setGettingError(e?.message ?? 'unknown error');
      }
      return undefined;
    } finally {
      setIsGetting(false);
    }
  };

  const getRaceIds = async () => {
    setIsGetting(true);
    try {
        const response = (await fetchJson('/api/raceId')) as {
            name: string;
            createdAt: Date;
        }[];
        setGettingError('');
        setIsGetting(false);
        return response;
        }
    catch (e: any) {
        if (e instanceof FetchError) {
            setGettingError(e.data.message);
        } else {
            setGettingError(e?.message ?? 'unknown error');
        }
        return undefined;
    }
    finally {
        setIsGetting(false);
    }
    };


  return {
    getData,
    getRaceIds,
    gettingError,
    isGetting,
  };
};
