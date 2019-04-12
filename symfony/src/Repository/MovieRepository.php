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

    public function getNumberOfMovies(): string
    {
        $entityManager = $this->getEntityManager();

        $countQuery= $entityManager->createQueryBuilder('m')
            ->select('count(m)')
            ->from('App:Movie', 'm')
            ->getQuery();

        return $countQuery->getSingleScalarResult();
    }

    public function getLastUpdate(): string
    {
        $entityManager = $this->getEntityManager();

        $lastUpdateQuery = $entityManager->createQueryBuilder('m')
            ->select('max(m.updatedAt)')
            ->from('App:Movie', 'm')
            ->getQuery();

        return $lastUpdateQuery->getSingleScalarResult();
    }

    public function getTotalTimeSpent(): array
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

    public function getRuntime(string $mathFunc): array
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

    public function getGenres(): array
    {
        $entityManager = $this->getEntityManager();

        $topGenresQuery= $entityManager->createQueryBuilder('m')
            ->select('m.genre, count(m.genre)')
            ->from('App:Movie', 'm')
            ->groupBy('m.genre')
            ->orderBy('count(m.genre)', 'DESC')
            ->setMaxResults(10)
            ->getQuery();

        $topGenres = $topGenresQuery->getScalarResult();

        return $topGenres;
    }

    public function getPrincipals(string $principals): array
    {
        $entityManager = $this->getEntityManager();

        $rsm = new ResultSetMapping($entityManager);
        $rsm->addEntityResult('App\Entity\Movie', 'm');
        $rsm->addFieldResult('m', $principals, $principals);
        $rsm->addScalarResult('principal', 'principal');
        $rsm->addScalarResult('count', 'count');

        $topPrincipalsQuery = $entityManager->createNativeQuery(
            "select unnest(string_to_array(".$principals.", ',')) as principal, count(*) as count
            from movie
            group by unnest(string_to_array(".$principals.", ','))
            order by count DESC
            limit 10",
            $rsm);

        $topPrincipals = $topPrincipalsQuery->getScalarResult();

        return $topPrincipals;
    }

    public function getAllData(): array
    {
        return [
            'numberOfMovies' => $this->getNumberOfMovies(),
            'lastUpdate' => $this->getLastUpdate(),
            'totalTimeSpent' => $this->getTotalTimeSpent(),
            'longestMovie' => $this->getRuntime('max'),
            'shortestMovie' => $this->getRuntime('min'),
            'averageRuntime' => $this->getRuntime('avg'),
            'topGenres' => $this->getGenres(),
            'topActors' => $this->getPrincipals('top_actors'),
            'topDirectors' => $this->getPrincipals('directors'),
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
