<?php

namespace App\Tests\Repository;

class MovieRepositoryTestHelpers
{
    public static function days(int $minutes): int
    {
        return round($minutes / 1440);
    }

    public static function hours(int $minutes): int
    {
        return floor($minutes / 60);
    }

    public static function remainingMinutes(int $minutes): int
    {
        return $minutes % 60;
    }

    public static function hoursAndMinutes(int $minutes): string
    {
        $hours = self::hours($minutes);
        $remainingMinutes = self::remainingMinutes($minutes);

        return $hours.$remainingMinutes;
    }
}
