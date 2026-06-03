import { Link } from "react-router-dom";
import Button from "./Button.jsx";

export default function SplitFeature({
  title,
  description,
  image,
  primary = "Get started",
  primaryTo = "/become-a-rider",
  secondary,
  secondaryTo = "/login",
  reverse = false,
  id,
}) {
  return (
    <section id={id} className="bg-white py-12 sm:py-16">
      <div
        className={`section-shell grid items-center gap-8 md:grid-cols-2 md:gap-14 ${
          reverse ? "md:[&>*:first-child]:order-2" : ""
        }`}
      >
        <div>{image}</div>
        <div className="max-w-lg">
          <h2 className="font-display text-3xl font-bold leading-tight sm:text-4xl">
            {title}
          </h2>
          <p className="mt-5 text-base font-medium leading-relaxed text-muted">
            {description}
          </p>
          <div className="mt-6 flex flex-wrap items-center gap-4">
            <Button to={primaryTo}>{primary}</Button>
            {secondary && (
              <Link
                to={secondaryTo}
                className="focus-ring rounded-lg py-3 text-sm font-bold text-muted hover:text-ink"
              >
                {secondary}
              </Link>
            )}
          </div>
        </div>
      </div>
    </section>
  );
}
