import { CalendarClock, ShieldCheck, TimerReset } from "lucide-react";
import { ReserveArt } from "./Illustrations.jsx";

const benefits = [
  {
    title: "Choose your exact pickup time up to 90 days in advance",
    Icon: CalendarClock,
  },
  {
    title: "Extra wait time included to meet your ride",
    Icon: TimerReset,
  },
  {
    title: "Cancel at no charge up to 60 minutes in advance",
    Icon: ShieldCheck,
  },
];

export default function ReserveSection() {
  return (
    <section id="reserve" className="bg-white py-12 sm:py-16">
      <div className="section-shell">
        <h2 className="font-display text-3xl font-bold sm:text-4xl">
          Plan for later
        </h2>
        <div className="mt-6 grid items-center gap-8 lg:grid-cols-[1.55fr_1fr] lg:gap-12">
          <ReserveArt />
          <div>
            <h3 className="text-lg font-extrabold">Benefits</h3>
            <div className="mt-5 grid gap-5">
              {benefits.map(({ title, Icon }) => (
                <div key={title} className="grid grid-cols-[2rem_1fr] gap-4">
                  <Icon size={21} className="mt-0.5 text-ink" />
                  <p className="text-sm font-semibold leading-relaxed text-muted">
                    {title}
                  </p>
                </div>
              ))}
            </div>
            <a
              href="#ride"
              className="focus-ring mt-7 inline-flex rounded-lg text-sm font-bold text-muted hover:text-ink"
            >
              See terms
            </a>
          </div>
        </div>
      </div>
    </section>
  );
}
