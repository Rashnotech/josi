import { CheckCircle2 } from "lucide-react";
import Button from "../components/Button.jsx";
import logoUrl from "../assets/josi-logo.jpeg";

export default function RegistrationPage({ page }) {
  return (
    <main className="bg-white">
      <section className="py-10 sm:py-14 lg:py-16">
        <div className="section-shell grid gap-9 lg:grid-cols-[0.95fr_1fr] lg:items-start lg:gap-14">
          <div>
            <p className="text-sm font-extrabold uppercase text-josi-red">
              {page.eyebrow}
            </p>
            <h1 className="mt-4 max-w-2xl font-display text-[2.75rem] font-bold leading-[1.04] sm:text-6xl">
              {page.title}
            </h1>
            <p className="mt-5 max-w-xl text-lg font-medium leading-relaxed text-muted">
              {page.description}
            </p>

            <div className="mt-8 grid gap-4">
              {page.benefits.map((benefit) => (
                <div key={benefit} className="flex items-center gap-3">
                  <CheckCircle2 size={21} className="shrink-0 text-josi-red" />
                  <span className="font-bold text-ink">{benefit}</span>
                </div>
              ))}
            </div>

            <div className="mt-10 overflow-hidden rounded-lg bg-paper">
              <img
                src={logoUrl}
                alt="Josi Transport and Logistics logo"
                className="h-44 w-full object-contain p-5"
              />
            </div>
          </div>

          <form className="rounded-lg border border-line bg-white p-5 shadow-soft sm:p-7">
            <h2 className="font-display text-2xl font-bold">Start registration</h2>
            <div className="mt-6 grid gap-4">
              <label className="grid gap-2">
                <span className="text-sm font-extrabold">Full name</span>
                <input
                  className="focus-ring h-12 rounded-lg border border-line px-4 font-semibold"
                  placeholder="Enter your name"
                />
              </label>
              <label className="grid gap-2">
                <span className="text-sm font-extrabold">Phone number</span>
                <input
                  className="focus-ring h-12 rounded-lg border border-line px-4 font-semibold"
                  placeholder="+234"
                />
              </label>
              <label className="grid gap-2">
                <span className="text-sm font-extrabold">City</span>
                <input
                  className="focus-ring h-12 rounded-lg border border-line px-4 font-semibold"
                  placeholder="Lagos"
                />
              </label>
              <label className="grid gap-2">
                <span className="text-sm font-extrabold">{page.vehicleLabel}</span>
                <select className="focus-ring h-12 rounded-lg border border-line bg-white px-4 font-semibold">
                  {page.vehicleOptions.map((option) => (
                    <option key={option}>{option}</option>
                  ))}
                </select>
              </label>
            </div>
            <Button type="submit" variant="red" className="mt-6 w-full">
              {page.cta}
            </Button>
            <p className="mt-4 text-sm font-semibold leading-relaxed text-muted">
              By continuing, you agree to receive onboarding updates from Josi
              Transport and Logistics.
            </p>
          </form>
        </div>
      </section>
    </main>
  );
}
