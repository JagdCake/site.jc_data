<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Request;

use App\Entity\Movie;
use App\Repository\MovieRepository;

class MovieDataController extends AbstractController
{
    /**
     * @Route("/", name="index")
     */
    public function index(MovieRepository $repo): Response
    {
        return $this->render('movie_data/index.html.twig', [
            'movie_data' => $repo->findAll(),
        ]);
    }
}
