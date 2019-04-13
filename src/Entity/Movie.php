<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use Gedmo\Mapping\Annotation as Gedmo;

/**
 * @ORM\Entity(repositoryClass="App\Repository\MovieRepository")
 */
class Movie
{
    /**
     * @ORM\Id()
     * @ORM\GeneratedValue()
     * @ORM\Column(type="integer")
     */
    private $id;

    /**
     * @ORM\Column(type="string", length=9)
     */
    private $imdb_id;

    /**
     * @ORM\Column(type="string", length=100)
     */
    private $title;

    /**
     * @ORM\Column(type="smallint")
     */
    private $year_of_release;

    /**
     * @ORM\Column(type="smallint")
     */
    private $runtime;

    /**
     * @ORM\Column(type="string", length=100)
     */
    private $genre;

    /**
     * @ORM\Column(type="float")
     */
    private $imdb_rating;

    /**
     * @ORM\Column(type="simple_array")
     */
    private $directors = [];

    /**
     * @ORM\Column(type="simple_array")
     */
    private $top_actors = [];

    /**
     * @ORM\Column(type="string", length=30)
     */
    private $my_rating;

    /**
     * @ORM\Column(type="string", length=11)
     */
    private $watched_on;

    /**
     * @ORM\Column(type="text")
     */
    private $discussion;

    /**
     * @Gedmo\Timestampable(on="create")
     * @ORM\Column(name="created_at", type="datetime")
     */
    private $createdAt;

    /**
     * @Gedmo\Timestampable(on="update")
     * @ORM\Column(name="updated_at", type="datetime")
     */
    private $updatedAt;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getImdbId(): ?string
    {
        return $this->imdb_id;
    }

    public function setImdbId(string $imdb_id): self
    {
        $this->imdb_id = $imdb_id;

        return $this;
    }

    public function getTitle(): ?string
    {
        return $this->title;
    }

    public function setTitle(string $title): self
    {
        $this->title = $title;

        return $this;
    }

    public function getRuntime(): ?int
    {
        return $this->runtime;
    }

    public function setRuntime(int $runtime): self
    {
        $this->runtime = $runtime;

        return $this;
    }

    public function getGenre(): ?string
    {
        return $this->genre;
    }

    public function setGenre(string $genre): self
    {
        $this->genre = $genre;

        return $this;
    }

    public function getImdbRating(): ?float
    {
        return $this->imdb_rating;
    }

    public function setImdbRating(float $imdb_rating): self
    {
        $this->imdb_rating = $imdb_rating;

        return $this;
    }

    public function getYearOfRelease(): ?int
    {
        return $this->year_of_release;
    }

    public function setYearOfRelease(int $year_of_release): self
    {
        $this->year_of_release = $year_of_release;

        return $this;
    }

    public function getDirectors(): ?array
    {
        return $this->directors;
    }

    public function setDirectors(array $directors): self
    {
        $this->directors = $directors;

        return $this;
    }

    public function getTopActors(): ?array
    {
        return $this->top_actors;
    }

    public function setTopActors(array $top_actors): self
    {
        $this->top_actors = $top_actors;

        return $this;
    }

    public function getMyRating(): ?string
    {
        return $this->my_rating;
    }

    public function setMyRating(string $my_rating): self
    {
        $this->my_rating = $my_rating;

        return $this;
    }

    public function getWatchedOn(): ?string
    {
        return $this->watched_on;
    }

    public function setWatchedOn(string $watched_on): self
    {
        $this->watched_on = $watched_on;

        return $this;
    }

    public function getDiscussion(): ?string
    {
        return $this->discussion;
    }

    public function setDiscussion(?string $discussion): self
    {
        $this->discussion = $discussion;

        return $this;
    }

    public function getCreatedAt(): ?\DateTimeInterface
    {
        return $this->createdAt;
    }

    public function setCreatedAt(?\DateTimeInterface $createdAt): self
    {
        $this->createdAt = $createdAt;

        return $this;
    }

    public function getUpdatedAt(): ?\DateTimeInterface
    {
        return $this->updatedAt;
    }

    public function setUpdatedAt(?\DateTimeInterface $updatedAt): self
    {
        $this->updatedAt = $updatedAt;

        return $this;
    }
}
