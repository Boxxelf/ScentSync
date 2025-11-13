import { useState } from "react";
import clsx from "clsx";
import { stories } from "./stories.data";
import { SparkleIcon } from "./SparkleIcon";

export function FragranceStories() {
  const [activeStoryId, setActiveStoryId] = useState<string | null>(null);

  return (
    <section
      className="relative min-h-screen overflow-hidden bg-gradient-to-br from-[#f3e7ff] via-[#fce5f0] to-[#fff3e0] text-[#2f1f3a]"
      aria-labelledby="fragrance-heading"
    >
      <div className="noise-overlay pointer-events-none absolute inset-0" aria-hidden="true" />

      <div className="relative mx-auto flex min-h-screen w-full max-w-6xl flex-col px-6 py-14 sm:px-10 lg:px-16 lg:py-20">
        <header className="mb-10 flex flex-col gap-3 lg:gap-4">
          <p className="text-xs uppercase tracking-[0.4em] text-[#6f4a7c]">
            Replica Collection
          </p>
          <h1
            id="fragrance-heading"
            className="font-playfair text-4xl font-semibold text-[#2f1f3a] sm:text-5xl lg:text-[3.6rem]"
          >
            Choose Your Fragrance Story
          </h1>
          <p className="max-w-xl text-sm text-[#5e4c68]">
            Discover multisensory journeys crafted with seasonal blossoms and luminous accords.
          </p>
        </header>

        <div
          className="grid flex-1 grid-cols-[repeat(auto-fit,minmax(260px,1fr))] gap-6 sm:gap-8"
          role="list"
          aria-label="Fragrance stories"
        >
          {stories.map((story) => {
            const isActive = activeStoryId === story.id;

            return (
              <article
                key={story.id}
                role="listitem"
                className={clsx(
                  "group relative flex min-h-[360px] flex-col justify-between overflow-hidden rounded-[28px] border border-white/30 bg-white/18",
                  "backdrop-blur-xl shadow-[0_30px_60px_-20px_rgba(92,70,156,0.35)] transition-all duration-300 ease-[cubic-bezier(0.25,0.1,0.25,1.0)]",
                  "hover:-translate-y-2 hover:scale-[1.04] hover:border-white/60 focus-within:-translate-y-2 focus-within:scale-[1.04] focus-within:border-white/60"
                )}
                onMouseEnter={() => setActiveStoryId(story.id)}
                onMouseLeave={() => setActiveStoryId(null)}
                onFocus={() => setActiveStoryId(story.id)}
                onBlur={() => setActiveStoryId(null)}
              >
                <div
                  className="pointer-events-none absolute inset-0 bg-gradient-to-br from-white/45 via-transparent to-white/20 opacity-0 transition-opacity duration-300 group-hover:opacity-100 group-focus-within:opacity-100"
                  aria-hidden="true"
                />

                <div className="relative z-10 flex flex-col gap-5 p-8">
                  <div className="flex items-center gap-3">
                    <span className="inline-flex h-12 w-12 items-center justify-center rounded-full bg-gradient-to-br from-white/80 to-white/25 text-[#9b77b6] shadow-[0_10px_25px_rgba(156,119,182,0.25)]">
                      <SparkleIcon className="h-6 w-6" aria-hidden="true" />
                    </span>
                    <div>
                      <h2 className="font-playfair text-2xl font-semibold text-[#2f1f3a]">
                        {story.title}
                      </h2>
                      <p className="text-[11px] uppercase tracking-[0.3em] text-[#8c6ea4]">
                        {story.subtitle}
                      </p>
                    </div>
                  </div>

                  <div className="flex flex-wrap gap-2">
                    {story.tags.map((tag) => (
                      <span
                        key={tag}
                        className="rounded-full bg-white/40 px-3 py-1 text-[11px] font-semibold uppercase tracking-[0.35em] text-[#6f4a7c]"
                      >
                        {tag}
                      </span>
                    ))}
                  </div>

                  <p className="text-sm leading-relaxed text-[#5e4c68]">
                    {story.teaser}
                  </p>
                </div>

                <div
                  id={`notes-${story.id}`}
                  aria-live="polite"
                  aria-hidden={!isActive}
                  className={clsx(
                    "relative z-10 mt-auto bg-white/12 px-8 py-6 text-sm text-[#4d3a5a]",
                    "transition-all duration-300 ease-out",
                    isActive
                      ? "translate-y-0 opacity-100"
                      : "translate-y-4 opacity-0 group-hover:translate-y-0 group-hover:opacity-100 group-focus-within:translate-y-0 group-focus-within:opacity-100"
                  )}
                >
                  <h3 className="mb-2 text-xs font-semibold uppercase tracking-[0.25em] text-[#8c6ea4]">
                    Notes
                  </h3>
                  <ul className="flex flex-wrap gap-2 text-[11px] text-[#4d3a5a]/90">
                    {story.notes.map((note) => (
                      <li key={note} className="rounded-full border border-white/45 px-3 py-1">
                        {note}
                      </li>
                    ))}
                  </ul>
                  <p className="mt-3 text-xs text-[#4d3a5a]/80">{story.description}</p>
                </div>

                <div className="relative z-10 px-8 pb-8 pt-4">
                  <button
                    type="button"
                    className={clsx(
                      "relative inline-flex w-full items-center justify-center gap-2 rounded-full px-6 py-3 text-xs font-semibold uppercase tracking-[0.35em] text-[#472b56]",
                      "bg-gradient-to-r from-[#f5b0ff] via-[#fdd8af] to-[#fef9d7] shadow-[0_0_35px_rgba(255,188,255,0.45)]",
                      "transition-all duration-300 ease-[cubic-bezier(0.25,0.1,0.25,1.0)]",
                      "hover:-translate-y-1 hover:shadow-[0_0_48px_rgba(255,188,255,0.65)] focus:outline-none focus-visible:ring-4 focus-visible:ring-[#d8b4ff]/60 active:scale-95"
                    )}
                    aria-describedby={`notes-${story.id}`}
                    aria-expanded={isActive}
                  >
                    Begin Journey
                  </button>
                </div>
              </article>
            );
          })}
        </div>

        <footer className="mt-14 flex flex-col items-start gap-3 text-xs text-[#5e4c68] lg:mt-16">
          <span className="uppercase tracking-[0.4em] text-[#8c6ea4]">
            More Stories Coming Soon
          </span>
          <p className="max-w-lg leading-relaxed">
            Preview serene blooms, nocturnal accords, and luminous mists as we expand the Replica universe.
          </p>
        </footer>
      </div>
    </section>
  );
}

