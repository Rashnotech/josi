import { ArrowRight, CarFront } from "lucide-react";
import Button from "./Button.jsx";
import homeHero from "../assets/home.png";

export default function Hero() {
  return (
    <section
      id="ride"
      className="relative min-h-[calc(100svh-4rem)] overflow-hidden bg-josi-black text-white"
    >
      <div className="absolute inset-0">
        <img
          src={homeHero}
          alt=""
          className="h-full w-full object-cover object-center"
        />
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_78%_22%,rgba(236,17,26,0.22),transparent_24rem),linear-gradient(90deg,rgba(0,0,0,0.92)_0%,rgba(0,0,0,0.7)_42%,rgba(0,0,0,0.28)_100%)]" />
        <div className="absolute inset-x-0 bottom-0 h-48 bg-gradient-to-t from-black/55 to-transparent" />
      </div>

      <div className="section-shell relative flex min-h-[calc(100svh-4rem)] items-center py-16 sm:py-20 lg:py-24">
        <div className="max-w-3xl">
          <div className="mb-7 inline-flex items-center gap-2 rounded-full border border-white/15 bg-white/10 px-4 py-2 text-sm font-extrabold text-white/85 backdrop-blur">
            <CarFront size={17} />
            Josi rides
          </div>

          <h1 className="max-w-2xl font-display text-[2.85rem] font-bold leading-[1.04] text-white sm:text-6xl lg:text-[4.9rem]">
            Go anywhere with Josi
          </h1>

          <p className="mt-5 max-w-xl text-base font-semibold leading-relaxed text-white/78 sm:text-xl">
            Request reliable rides, move around your city with ease, and get
            where you need to be on your own schedule.
          </p>

          <Button
            to="/become-a-rider"
            variant="red"
            className="mt-8 min-h-14 rounded-lg px-7 text-lg shadow-[0_18px_38px_rgba(236,17,26,0.28)]"
          >
            Get rider
            <ArrowRight size={20} className="ml-2" />
          </Button>
        </div>
      </div>
    </section>
  );
}
