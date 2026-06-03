import { ArrowRight, CalendarClock, CarFront, PackageCheck } from "lucide-react";
import { Link } from "react-router-dom";
import bikesImage from "../assets/bikes.png";
import calendarImage from "../assets/calendar.jpeg";
import parcelImage from "../assets/parcel.jpeg";

const services = [
  {
    title: "Ride",
    description: "Go anywhere with Josi. Request a ride, hop in, and go.",
    Icon: CarFront,
    image: bikesImage,
    imageAlt: "Josi branded bikes",
    imagePosition: "object-center",
    ctaTo: "/become-a-rider",
  },
  {
    title: "Reserve",
    description: "Reserve your ride in advance so you can relax on the day of your trip.",
    Icon: CalendarClock,
    image: calendarImage,
    imageAlt: "Calendar and clock",
    imagePosition: "object-center",
    ctaHref: "#reserve",
  },
  {
    title: "Courier",
    description: "Move packages across the city with delivery options that fit your day.",
    Icon: PackageCheck,
    image: parcelImage,
    imageAlt: "Courier carrying a parcel",
    imagePosition: "object-center",
    ctaTo: "/become-a-courier",
  },
];

export default function ExploreCards() {
  return (
    <section className="bg-white pb-12 sm:pb-16">
      <div className="section-shell">
        <h2 className="font-display text-2xl font-bold leading-tight sm:text-3xl">
          Explore what you can do with Josi
        </h2>

        <div className="mt-6 grid gap-4 md:grid-cols-3">
          {services.map(
            ({
              title,
              description,
              Icon,
              image,
              imageAlt,
              imagePosition,
              ctaHref,
              ctaTo,
            }) => (
            <article
              key={title}
              className="grid min-h-36 grid-cols-[1fr_auto] gap-4 overflow-hidden rounded-lg bg-paper p-4"
            >
              <div>
                <div className="flex items-center gap-2">
                  <Icon size={18} className="text-josi-red" />
                  <h3 className="text-base font-extrabold">{title}</h3>
                </div>
                <p className="mt-3 max-w-[15rem] text-sm font-medium leading-relaxed text-muted">
                  {description}
                </p>
                {ctaTo ? (
                  <Link
                    to={ctaTo}
                    className="focus-ring mt-4 inline-flex items-center gap-2 rounded-full bg-white px-4 py-2 text-xs font-extrabold text-ink"
                  >
                    Details <ArrowRight size={14} />
                  </Link>
                ) : (
                  <a
                    href={ctaHref}
                    className="focus-ring mt-4 inline-flex items-center gap-2 rounded-full bg-white px-4 py-2 text-xs font-extrabold text-ink"
                  >
                    Details <ArrowRight size={14} />
                  </a>
                )}
              </div>
              <div className="h-24 w-28 overflow-hidden rounded-lg bg-white sm:h-28 sm:w-32">
                <img
                  src={image}
                  alt={imageAlt}
                  className={`h-full w-full object-cover ${imagePosition}`}
                  loading="lazy"
                />
              </div>
            </article>
            ),
          )}
        </div>
      </div>
    </section>
  );
}
