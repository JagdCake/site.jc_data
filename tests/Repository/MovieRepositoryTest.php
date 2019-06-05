<?php

namespace App\Tests\Repository;

use App\Entity\Movie;
use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;
use App\Tests\Repository\MovieRepositoryTestHelpers as Helpers;

class MovieRepositoryTest extends KernelTestCase
{

    private $entityManager;

    protected function setUp()
    {
        $kernel = self::bootKernel();

        $this->entityManager = $kernel->getContainer()
             ->get('doctrine')
             ->getManager();
    }

    public function testFindsCorrectNumberOfMovies()
    {
        $numOfMovies = $this->entityManager
            ->getRepository(Movie::class)
            ->totalNumberOfMovies();

        $this->assertEquals(
            '3',
            $numOfMovies,
        );
    }

    public function testTimeSpentIsCorrect()
    {
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

    public function testCorrectlyCalculatesRuntime()
    {
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

    public function testExtractingPrincipalsWorks()
    {
        $topActors = $this->entityManager
            ->getRepository(Movie::class)
            ->principals('top_actors');

        $topFixtureActor = 'Test Actor 1'; // stars in all 3 data fixture movies
        $topFixtureActorCount = 3;

        $this->assertEquals(
            $topFixtureActor,
            $topActors[0]['principal'],
        );

        $this->assertEquals(
            $topFixtureActorCount,
            $topActors[0]['count'],
        );
    }

    public function testTranslatingImdbRatingsWorks()
    {
        $transRatings = $this->entityManager
            ->getRepository(Movie::class)
            ->translatedImdbRatings();

        $this->assertEquals(
            // all data fixture movies have IMDb ratings under 4.0 which I consider to be a 'Bad Eggplant'
            3,
            // in the $transRatings array 'Bad Eggplant' is initialized at index 5
            // but translatedImdbRatings() returns the array sorted by count, in descending order,
            // which puts the 'Bad Eggplants' at index 0
            $transRatings[0]['count'],
            'The number of Bad Eggplants should equal the number of fixture movies because they are all rated < 4.0',
        );
    }

    public function testCorrectlyCalculatesRatingsScore()
    {
        $repo = $this->entityManager
            ->getRepository(Movie::class);
            
        $imdbRatings = [
            0 => [
                'rating' => 'Bad Eggplant',
                'count' => '3',
            ],
        ];

        $myRatings = [
            0 => [
                'rating' => 'Bad Eggplant',
                'count' => '1',
            ],
            1 => [
                'rating' => 'Decent Carrot',
                'count' => '2',
            ],
        ];

        $imdbScore = $repo->ratingsScore($imdbRatings);
        $myScore = $repo->ratingsScore($myRatings);

        $eggplantScore = 1;
        $carrotScore = 2;

        $this->assertEquals(
            $imdbRatings[0]['count'] * $eggplantScore,
            $imdbScore,
        );

        $this->assertEquals(
            ($myRatings[0]['count'] * $eggplantScore) + ($myRatings[1]['count'] * $carrotScore),
            $myScore,
        );
    }

    public function testRatingScoresAreComparedCorrectly()
    {
        $ratingsAdjective = $this->entityManager
            ->getRepository(Movie::class)
            ->ratingsScoreComparison();

        $this->assertEquals(
            'lower',
            $ratingsAdjective,
            'IMDb users should give lower ratings because their translated ratings are 3 Bad Eggplants while mine are 3 Great Onions',
        );
    }

    protected function tearDown()
    {
        parent::tearDown();

        $this->entityManager->close();
        $this->entityManager = null;
    }
}
