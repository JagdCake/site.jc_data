<?php

namespace App\Repository;

use App\Entity\Movie;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Symfony\Bridge\Doctrine\RegistryInterface;
use Doctrine\ORM\Query\ResultSetMapping;

/**
 * @method Movie|null find($id, $lockMode = null, $lockVersion = null)
 * @method Movie|null findOneBy(array $criteria, array $orderBy = null)
 * @method Movie[]    findAll()
 * @method Movie[]    findBy(array $criteria, array $orderBy = null, $limit = null, $offset = null)
 */
class MovieRepository extends ServiceEntityRepository
{
    public function __construct(RegistryInterface $registry)
    {
        parent::__construct($registry, Movie::class);
    }

    public function totalNumberOfMovies(): string
    {
        $entityManager = $this->getEntityManager();

        $countQuery= $entityManager->createQueryBuilder('m')
            ->select('count(m)')
            ->from('App:Movie', 'm')
            ->getQuery();

        return $countQuery->getSingleScalarResult();
    }

    public function dateOfLastUpdate(): string
    {
        $entityManager = $this->getEntityManager();

        $lastUpdateQuery = $entityManager->createQueryBuilder('m')
            ->select('max(m.updatedAt)')
            ->from('App:Movie', 'm')
            ->getQuery();

        return $lastUpdateQuery->getSingleScalarResult();
    }

    public function totalTimeSpent(): array
    {
        $entityManager = $this->getEntityManager();

        $totalRuntimeQuery= $entityManager->createQueryBuilder('m')
            ->select('sum(m.runtime)')
            ->from('App:Movie', 'm')
            ->getQuery();

        $totalRuntime = $totalRuntimeQuery->getSingleScalarResult();

        return [
            'days' => round($totalRuntime / 1440),
            'hours' => floor($totalRuntime / 60),
            'remainingMinutes' => $totalRuntime % 60,
        ];
    }

    /**
     * Converts specific runtime value into hours and minutes
     *
     * @param string $mathFunc the SQL function (max, min, avg) to use to find a runtime value to convert
     *
     * @return array the runtime value converted from minutes into hours and minutes
     */
    public function runtime(string $mathFunc): array
    {
        $entityManager = $this->getEntityManager();

        $runtimeQuery= $entityManager->createQueryBuilder('m')
            ->select($mathFunc.'(m.runtime)')
            ->from('App:Movie', 'm')
            ->getQuery();

        $runtime = $runtimeQuery->getSingleScalarResult();

        return [
            'hours' => floor($runtime / 60),
            'minutes' => $runtime % 60,
        ];
    }

    /**
     * Finds a number of database field's values and their counts
     *
     * @param string $field the name of the database field to query for
     * @param string $alias prettified field name
     * @param int $results the number of query results
     *
     * @return array the top (by count) field values and their counts
     */
    public function fieldValueCount(string $field, string $alias, int $results = 10): array
    {
        $entityManager = $this->getEntityManager();

        $fieldQuery= $entityManager->createQueryBuilder('m')
            ->select('m.'.$field.' as '.$alias.', count(m) as count')
            ->from('App:Movie', 'm')
            ->groupBy('m.'.$field)
            ->orderBy('count(m.'.$field.')', 'DESC')
            ->setMaxResults($results)
            ->getQuery();

        return $fieldQuery->getScalarResult();
    }

    /**
     * Extracts the decade from every movie's release year and sorts the decades in descending order by count
     *
     * @return array the top 10 decades and their counts
     */
    public function decades(): array
    {
        $entityManager = $this->getEntityManager();

        $rsm = new ResultSetMapping($entityManager);
        $rsm->addEntityResult('App\Entity\Movie', 'm');
        $rsm->addFieldResult('m', 'year_of_release', 'year_of_release');
        $rsm->addScalarResult('decade', 'decade');
        $rsm->addScalarResult('count', 'count');

        $decadesQuery= $entityManager->createNativeQuery(
            "select extract(decade from to_date(year_of_release::text, 'YYYY')) as decade, count(*) as count
            from movie
            group by extract(decade from to_date(year_of_release::text, 'YYYY'))
            order by count DESC
            limit 10",
            $rsm);

        return $decadesQuery->getScalarResult();
    }

    /**
     * principals = actors / directors
     * Converts the comma separated names of principals into an array and sorts them in descending order by count
     *
     * @param string $field the name of a principals field (top_actors or directors)
     *
     * @return array the top 10 names of principals and their counts
     */
    public function principals(string $field): array
    {
        $entityManager = $this->getEntityManager();

        $rsm = new ResultSetMapping($entityManager);
        $rsm->addEntityResult('App\Entity\Movie', 'm');
        $rsm->addFieldResult('m', $field, $field);
        $rsm->addScalarResult('principal', 'principal');
        $rsm->addScalarResult('count', 'count');

        $topPrincipalsQuery = $entityManager->createNativeQuery(
            "select unnest(string_to_array(".$field.", ',')) as principal, count(*) as count
            from movie
            group by unnest(string_to_array(".$field.", ','))
            order by count DESC
            limit 10",
            $rsm);

        return $topPrincipalsQuery->getScalarResult();
    }

    public function allImdbRatings(): array
    {
        $entityManager = $this->getEntityManager();

        $imdbRatingsQuery= $entityManager->createQueryBuilder('m')
            ->select('m.imdb_rating as rating')
            ->from('App:Movie', 'm')
            ->orderBy('m.imdb_rating', 'DESC')
            ->getQuery();

        return $imdbRatingsQuery->getScalarResult();
    }

    /**
     * Translates IMDb ratings into my rating system
     *
     * @return array $transRatings the translated rating values and their counts
     */
    public function translatedImdbRatings(): array
    {
        $imdbRatings = $this->allImdbRatings();

        $transRatings = [
            0 => [
                'rating' => 'Sublime Lettuce',
                'count' => 0,
            ],
            1 => [
                'rating' => 'Amazing Savory',
                'count' => 0,
            ],
            2 => [
                'rating' => 'Great Onion',
                'count' => 0,
            ],
            3 => [
                'rating' => 'Good Tomato',
                'count' => 0,
            ],
            4 => [
                'rating' => 'Decent Carrot',
                'count' => 0,
            ],
            5 => [
                'rating' => 'Bad Eggplant',
                'count' => 0,
            ],
        ];

        foreach($imdbRatings as $ratingData) {
            if($ratingData['rating'] >= 9) {
                $i = 0;
            }elseif($ratingData['rating'] >= 7.9) {
                $i = 1;
            }elseif($ratingData['rating'] >= 6) {
                $i = 2;
            }elseif($ratingData['rating'] >= 5) {
                $i = 3;
            }elseif($ratingData['rating'] >= 4) {
                $i = 4;
            }elseif($ratingData['rating'] >= 1) {
                $i = 5;
            }

            $transRatings[$i]['count'] += 1;
        }

        // sort the ratings by count in descending order
        usort($transRatings, function($item1, $item2) {
            return $item2['count'] <=> $item1['count'];
        });
        return $transRatings;
    }

    /**
     * Generates a numeric score by scoring every rating (from my rating system) with a number in the range 1–6
     *
     * @param array $ratings ratings data
     *
     * @return int $score the total score of the ratings data
     */
    public function ratingsScore(array $ratings): int
    {
        // points score
        $score = 0;

        foreach($ratings as $ratingData) {
            if($ratingData['rating'] == 'Sublime Lettuce') {
                $points = 6;
            }elseif($ratingData['rating'] == 'Amazing Savory') {
                $points = 5;
            }elseif($ratingData['rating'] == 'Great Onion') {
                $points = 4;
            }elseif($ratingData['rating'] == 'Good Tomato') {
                $points = 3;
            }elseif($ratingData['rating'] == 'Decent Carrot') {
                $points = 2;
            }elseif($ratingData['rating'] == 'Bad Eggplant') {
                $points = 1;
            }

            $score += $ratingData['count'] * $points;
        }

        return $score;
    }

    /**
     * Determines how IMDb users rate movies compared to me
     *
     * @return string $ratingAdjective
     */
    public function ratingsScoreComparison(): string
    {
        $imdbScore = $this->ratingsScore($this->translatedImdbRatings());
        $myScore = $this->ratingsScore($this->fieldValueCount('my_rating', 'rating'));

        if($imdbScore > $myScore) {
            $ratingAdjective = 'higher';
        }elseif($imdbScore < $myScore) {
            $ratingAdjective = 'lower';
        }else {
            $ratingAdjective = 'the same';
        }

        return $ratingAdjective;
    }

    public function allData(): array
    {
        return [
            'totalNumberOfMovies' => $this->totalNumberOfMovies(),
            'dateOfLastUpdate' => $this->dateOfLastUpdate(),
            'totalTimeSpent' => $this->totalTimeSpent(),
            'longestMovie' => $this->runtime('max'),
            'shortestMovie' => $this->runtime('min'),
            'averageRuntime' => $this->runtime('avg'),
            'topGenres' => $this->fieldValueCount('genre', 'genre'),
            'topActors' => $this->principals('top_actors'),
            'topDirectors' => $this->principals('directors'),
            'topYear' => $this->fieldValueCount('year_of_release', 'year', 1),
            'decades' => $this->decades(),
            'myRatings' => $this->fieldValueCount('my_rating', 'rating'),
            'imdbRatings' => $this->translatedImdbRatings(),
            'ratingAdjective' => $this->ratingsScoreComparison(),
        ];
    }
    // /**
    //  * @return Movie[] Returns an array of Movie objects
    //  */
    /*
    public function findByExampleField($value)
    {
        return $this->createQueryBuilder('m')
            ->andWhere('m.exampleField = :val')
            ->setParameter('val', $value)
            ->orderBy('m.id', 'ASC')
            ->setMaxResults(10)
            ->getQuery()
            ->getResult()
        ;
    }
    */

    /*
    public function findOneBySomeField($value): ?Movie
    {
        return $this->createQueryBuilder('m')
            ->andWhere('m.exampleField = :val')
            ->setParameter('val', $value)
            ->getQuery()
            ->getOneOrNullResult()
        ;
    }
    */
}
