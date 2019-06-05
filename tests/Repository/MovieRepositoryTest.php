<?php

namespace App\Tests\Repository;

use App\Entity\Movie;
use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;
use App\Tests\Repository\MovieRepositoryTestHelpers as Helpers;

class MovieRepositoryTest extends KernelTestCase
{

    private $entityManager;

    protected function setUp() {
        $kernel = self::bootKernel();

        $this->entityManager = $kernel->getContainer()
             ->get('doctrine')
             ->getManager();
    }

    public function testFindsCorrectNumberOfMovies() {
        $numOfMovies = $this->entityManager
            ->getRepository(Movie::class)
            ->totalNumberOfMovies();

        $this->assertEquals(
            '3',
            $numOfMovies,
        );
    }

    public function testTimeSpentIsCorrect() {
        $timeSpent = $this->entityManager
            ->getRepository(Movie::class)
            ->totalTimeSpent();

        // the total runtime (minutes) of the fixture movies
        $totalFixtureRuntime = 273;

        $days = Helpers::days($totalFixtureRuntime);
        $this->assertEquals(
            $days,
            $timeSpent['days'],
        );

        $hours = Helpers::hours($totalFixtureRuntime);
        $this->assertEquals(
            $hours,
            $timeSpent['hours'],
        );

        $remainingMinutes = Helpers::remainingMinutes($totalFixtureRuntime);
        $this->assertEquals(
            $remainingMinutes,
            $timeSpent['remainingMinutes'],
        );
    }

    public function testCorrectlyCalculatesRuntime() {
        $repo = $this->entityManager
            ->getRepository(Movie::class);

        // data fixture runtimes (minutes)
        $longestFixtureRuntime = 92;
        $shortestFixtureRuntime = 90;
        $averageFixtureRuntime = 91;

        $hoursAndMinutes = Helpers::hoursAndMinutes($longestFixtureRuntime);
        $longestRuntime = $repo->runtime('max');

        $this->assertEquals(
            $hoursAndMinutes,
            $longestRuntime['hours'].$longestRuntime['minutes'],
        );

        $hoursAndMinutes = Helpers::hoursAndMinutes($shortestFixtureRuntime);
        $shortestRuntime = $repo->runtime('min');

        $this->assertEquals(
            $hoursAndMinutes,
            $shortestRuntime['hours'].$shortestRuntime['minutes'],
        );

        $hoursAndMinutes = Helpers::hoursAndMinutes($averageFixtureRuntime);
        $averageRuntime = $repo->runtime('avg');

        $this->assertEquals(
            $hoursAndMinutes,
            $averageRuntime['hours'].$averageRuntime['minutes'],
        );
    }

    public function testFieldValueCountsAreCorrect()
    {
        $repo = $this->entityManager
            ->getRepository(Movie::class);

        $topFixtureGenre = 'testGenre';
        $topFixtureGenreCount = 3;

        $topGenres = $repo->fieldValueCount('genre', 'genre');

        $this->assertEquals(
            $topFixtureGenre,
            $topGenres[0]['genre'],
        );

        $this->assertEquals(
            $topFixtureGenreCount,
            $topGenres[0]['count'],
        );
    }

    public function testExtractingDecadesWorks()
    {
        $decades = $this->entityManager
            ->getRepository(Movie::class)
            ->decades();

        // all data fixture movies are released in the 2000s
        $fixtureMoviesDecade = 200;
        $fixtureMoviesDecadeCount = 3;

        $this->assertEquals(
            $fixtureMoviesDecade,
            $decades[0]['decade'],
        );

        $this->assertEquals(
            $fixtureMoviesDecadeCount,
            $decades[0]['count'],
        );
    }

    protected function tearDown() {
        parent::tearDown();

        $this->entityManager->close();
        $this->entityManager = null;
    }
}
