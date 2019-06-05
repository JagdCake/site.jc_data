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

    public function testCorrectlyCalculatesTimeSpent() {
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

    protected function tearDown() {
        parent::tearDown();

        $this->entityManager->close();
        $this->entityManager = null;
    }
}
