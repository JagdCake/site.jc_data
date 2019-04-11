<?php

namespace App\Repository;

use App\Entity\Movie;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Symfony\Bridge\Doctrine\RegistryInterface;

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
        $idQuery= $entityManager->createQueryBuilder('m')
            ->select('max(m.id)')
            ->from('App:Movie', 'm')
            ->getQuery();

        $lastId = $idQuery->getSingleScalarResult();

        $dateQuery = $entityManager->createQueryBuilder('m')
            ->select('m.updatedAt')
            ->from('App:Movie', 'm')
            ->where('m.id = :lastId')
            ->setParameter('lastId', $lastId)
            ->getQuery();

        return $dateQuery->getSingleScalarResult();
    }

    public function getAllData(): array
    {
        return [
            'numberOfMovies' => $this->getNumberOfMovies(),
            'lastUpdate' => $this->getLastUpdate(),
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
