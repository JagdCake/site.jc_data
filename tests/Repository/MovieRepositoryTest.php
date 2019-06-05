<?php

namespace App\Tests\Repository;

use App\Entity\Movie;
use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;

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

    protected function tearDown() {
        parent::tearDown();

        $this->entityManager->close();
        $this->entityManager = null;
    }
}
