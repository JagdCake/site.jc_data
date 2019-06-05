<?php

namespace App\DataFixtures;

use App\Entity\Movie;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Common\Persistence\ObjectManager;

class MoviesFixture extends Fixture
{
    public function load(ObjectManager $manager)
    {
        for($i = 0; $i < 3; $i++) {
            $movie = new Movie();
            $movie->setImdbId('tt000000'.$i);
            $movie->setTitle('Test Movie '.$i);
            $movie->setRuntime(90 + $i);
            $movie->setGenre('testGenre');
            $movie->setImdbRating("1.$i");
            $movie->setYearOfRelease("200$i");
            $movie->setDirectors(['Test Director']);
            $movie->setTopActors(['Test Actor 1', 'Test Actor 2']);
            $movie->setMyRating('Test Onion');
            $movie->setWatchedOn('0'.$i.' Apr 2019');
            $movie->setDiscussion('test link');

            $manager->persist($movie);
        }

        $manager->flush();
    }
}
