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
            'movieData' => $repo->allData(),
        ]);
    }

    /**
     * @Route("/generate", name="generateStaticSite", methods={"GET"})
     */
    public function generateStaticSite(MovieRepository $repo): Response
    {
        $content = $this->renderView('movie_data/index.html.twig', [
            'movieData' => $repo->allData(),
        ]);

        $file = file_put_contents('../docs/index.html', $content);

        return $this->redirectToRoute('index');
    }
}
