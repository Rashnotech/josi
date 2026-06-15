import {
  BarChart3,
  BriefcaseBusiness,
  CarFront,
  CheckCircle2,
  Clock3,
  CreditCard,
  LayoutDashboard,
  ShieldCheck,
  UsersRound,
} from "lucide-react";
import { Link } from "react-router-dom";
import Button from "../components/Button.jsx";
import AuthRegistrationForm from "../components/AuthRegistrationForm.jsx";
import courierImage from "../assets/courier.png";
import scooterImage from "../assets/scooter.png";

const partnerBenefits = [
  {
    title: "Strong, stable earnings",
    description: "Reliable returns with consistent rider demand.",
    Icon: CreditCard,
  },
  {
    title: "Complete transparency",
    description: "A sleek portal to manage every part of your pack business.",
    Icon: LayoutDashboard,
  },
  {
    title: "Great customer support",
    description: "Short response times for business-related queries.",
    Icon: ShieldCheck,
  },
];

const setupSteps = [
  {
    title: "Sign up",
    description:
      "It takes a few minutes to register your pack company account.",
    Icon: BriefcaseBusiness,
  },
  {
    title: "Get approved",
    description:
      "Add pack details such as vehicles, riders, and activation documents.",
    Icon: CheckCircle2,
  },
  {
    title: "Start earning",
    description:
      "Once approved, your vehicles are ready to start earning on the roads.",
    Icon: CarFront,
  },
];

const portalHighlights = [
  {
    title: "Access earnings data in real-time",
    description: "24/7 metrics updated around the clock.",
  },
  {
    title: "Track riders and vehicles",
    description: "See availability, activity, and status from one dashboard.",
  },
  {
    title: "Review performance reports",
    description: "Understand trips, payouts, demand, and operations trends.",
  },
];

function ImagePlaceholder({ label, className = "", children }) {
  return (
    <div
      className={`grid place-items-center overflow-hidden rounded-lg border border-dashed border-josi-red/35 bg-[linear-gradient(135deg,#111,#4a0a0d_54%,#f6f6f6)] text-center ${className}`}
    >
      <div className="grid justify-items-center gap-3 px-5">
        {children && <span className="text-josi-red">{children}</span>}
        <span className="text-xs font-extrabold uppercase tracking-normal text-white/82">
          {label}
        </span>
      </div>
    </div>
  );
}

function PackSignupForm() {
  return (
    <div className="w-full min-w-0">
      <AuthRegistrationForm
        role="pack_owner"
        title="Add your pack"
        submitLabel="Continue"
        business
      />
      <p className="mt-4 text-sm font-semibold text-white/82">
        Already have an account?{" "}
        <Link to="/login" className="font-extrabold text-josi-red">
          Log in
        </Link>
      </p>
    </div>
  );
}

function BenefitItem({ item }) {
  const { Icon } = item;

  return (
    <article className="grid gap-3 rounded-lg bg-white p-5 shadow-soft">
      <span className="grid size-9 place-items-center rounded-full bg-josi-red text-white">
        <Icon size={18} />
      </span>
      <h3 className="text-base font-extrabold text-ink">{item.title}</h3>
      <p className="text-sm font-medium leading-relaxed text-muted">
        {item.description}
      </p>
    </article>
  );
}

function StepItem({ item }) {
  const { Icon } = item;

  return (
    <article className="grid gap-3 rounded-lg bg-white p-5 shadow-soft">
      <span className="grid size-9 place-items-center rounded-full bg-josi-black text-white">
        <Icon size={18} />
      </span>
      <h3 className="text-base font-extrabold text-ink">{item.title}</h3>
      <p className="text-sm font-medium leading-relaxed text-muted">
        {item.description}
      </p>
    </article>
  );
}

function PortalPreview() {
  return (
    <div className="relative min-h-[24rem] overflow-hidden rounded-lg bg-white">
      <div className="absolute right-0 top-0 h-full w-[68%] bg-josi-red/10" />
      <div className="absolute left-[30%] top-12 w-[62%] rounded-lg bg-white p-5 shadow-soft ring-1 ring-black/5">
        <div className="flex items-center justify-between border-b border-line pb-4">
          <span className="font-display text-lg font-bold text-josi-red">
            Josi Pack
          </span>
          <span className="rounded-full bg-josi-red px-3 py-1 text-xs font-bold text-white">
            Reports
          </span>
        </div>
        <h3 className="mt-6 text-2xl font-extrabold">Reports</h3>
        <div className="mt-5 grid grid-cols-3 gap-3">
          {["9,786", "2,440", "7,346"].map((value) => (
            <div key={value} className="rounded-lg bg-paper p-3">
              <p className="text-xs font-bold text-muted">Metric</p>
              <p className="mt-1 text-lg font-extrabold">{value}</p>
            </div>
          ))}
        </div>
        <div className="mt-6 grid gap-2">
          {Array.from({ length: 6 }).map((_, index) => (
            <span key={index} className="h-3 rounded-full bg-line" />
          ))}
        </div>
      </div>
      <div className="absolute -right-20 top-20 hidden w-64 rounded-lg bg-white p-5 opacity-60 shadow-soft ring-1 ring-black/5 sm:block">
        <h3 className="text-2xl font-extrabold">Riders</h3>
        <div className="mt-6 grid gap-3">
          {Array.from({ length: 7 }).map((_, index) => (
            <span key={index} className="h-3 rounded-full bg-line" />
          ))}
        </div>
      </div>
    </div>
  );
}

export default function PackOwnerPage() {
  return (
    <main className="bg-white">
      <section className="relative overflow-hidden bg-josi-black text-white">
        <div className="absolute inset-0">
          <img
            src={scooterImage}
            alt=""
            className="h-full w-full object-cover object-[58%_center]"
          />
          <div className="absolute inset-0 bg-[linear-gradient(90deg,rgba(0,0,0,0.9)_0%,rgba(0,0,0,0.66)_50%,rgba(0,0,0,0.22)_100%)]" />
          <div className="absolute inset-0 bg-josi-red/10" />
        </div>

        <div className="section-shell relative grid min-w-0 gap-8 py-10 sm:py-14 lg:grid-cols-[minmax(0,1fr)_minmax(22rem,26rem)] lg:items-center lg:py-20">
          <div className="max-w-2xl">
            <h1 className="font-display text-[2rem] font-bold leading-[1.04] sm:text-6xl lg:text-[3rem]">
              Join Josi with your pack and earn more
            </h1>
            <p className="mt-5 max-w-xl text-base font-semibold leading-relaxed text-white/84 sm:text-lg">
              As a pack owner and Josi partner, you can manage your vehicles
              from one easy-to-use dashboard and grow your transport business.
            </p>
            <p className="mt-5 text-xs font-bold text-white/58">
              Before registering, make sure your pack has all required documents.
            </p>
          </div>

          <PackSignupForm />
        </div>
      </section>

      <section className="py-12 sm:py-16 lg:py-20">
        <div className="section-shell">
          <h2 className="font-display text-3xl font-bold leading-tight sm:text-5xl">
            Why partner with us?
          </h2>
          <p className="mt-4 max-w-3xl text-base font-medium leading-relaxed text-muted">
            Josi is built for pack partners who want clear operations, reliable
            rider demand, and useful tools for daily transport management.
          </p>

          <div className="mt-12 grid gap-8 sm:grid-cols-3">
            {partnerBenefits.map((item) => (
              <BenefitItem key={item.title} item={item} />
            ))}
          </div>
        </div>
      </section>

      <section id="pack-portal" className="overflow-hidden py-12 sm:py-16 lg:py-20">
        <div className="section-shell">
          <h2 className="font-display text-3xl font-bold leading-tight sm:text-5xl">
            How our pack portal works
          </h2>
          <p className="mt-4 max-w-3xl text-base font-medium leading-relaxed text-muted">
            Operate your business in real time with a management portal made for
            vehicles, riders, reports, and day-to-day pack operations.
          </p>
        </div>

        <div className="section-shell mt-8 grid gap-8 lg:grid-cols-[0.75fr_1.25fr] lg:items-center">
          <div>
            <h3 className="font-display text-3xl font-bold leading-tight sm:text-4xl">
              {portalHighlights[0].title}
            </h3>
            <p className="mt-4 text-sm font-semibold leading-relaxed text-muted">
              {portalHighlights[0].description}
            </p>
            <div className="mt-12 flex items-center gap-4">
              <span className="h-0.5 w-16 bg-josi-red" />
              <span className="text-sm font-extrabold text-muted">1/3</span>
            </div>
          </div>

          <PortalPreview />
        </div>
      </section>

      <section className="py-12 sm:py-16 lg:py-20">
        <div className="section-shell">
          <h2 className="font-display text-3xl font-bold leading-tight sm:text-5xl">
            Try our portal for free
          </h2>
          <p className="mt-4 text-base font-medium leading-relaxed text-muted">
            Set up in 3 easy steps:
          </p>

          <div className="mt-12 grid gap-8 sm:grid-cols-3">
            {setupSteps.map((item) => (
              <StepItem key={item.title} item={item} />
            ))}
          </div>
        </div>
      </section>

      <section className="pb-12 sm:pb-16 lg:pb-20">
        <div className="section-shell">
          <div className="relative overflow-hidden rounded-lg bg-josi-black p-7 text-white sm:p-10 lg:p-14">
            <div className="relative z-10 max-w-lg">
              <h2 className="font-display text-3xl font-bold leading-tight sm:text-5xl">
                Boost your pack earnings with Josi
              </h2>
              <p className="mt-5 text-base font-semibold text-white/72">
                Sign up takes a few minutes. Try it out today.
              </p>
              <Button variant="red" to="/sign-up-as-a-pack-owner" className="mt-7">
                Sign up now
              </Button>
            </div>

            <div className="mt-10 lg:absolute lg:bottom-0 lg:right-0 lg:mt-0 lg:w-[48%]">
              <div className="aspect-[1.65/1] overflow-hidden rounded-lg bg-white/5">
                <img
                  src={courierImage}
                  alt="Josi courier partner ready for pack delivery"
                  loading="lazy"
                  className="h-full w-full object-cover object-center"
                />
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="bg-paper py-12 sm:py-16">
        <div className="section-shell grid gap-6 sm:grid-cols-3">
          {portalHighlights.map((item, index) => (
            <article key={item.title} className="rounded-lg bg-white p-5 shadow-soft">
              <span className="grid size-10 place-items-center rounded-full bg-josi-red text-white">
                {index === 0 && <BarChart3 size={19} />}
                {index === 1 && <UsersRound size={19} />}
                {index === 2 && <Clock3 size={19} />}
              </span>
              <h3 className="mt-5 text-lg font-extrabold">{item.title}</h3>
              <p className="mt-2 text-sm font-medium leading-relaxed text-muted">
                {item.description}
              </p>
            </article>
          ))}
        </div>
      </section>
    </main>
  );
}
