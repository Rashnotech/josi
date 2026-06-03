import { useState } from "react";
import {
  CalendarClock,
  CheckCircle2,
  CircleDollarSign,
  MapPinned,
  Minus,
  Plus,
  WalletCards,
} from "lucide-react";
import Button from "../components/Button.jsx";
import applyImage from "../assets/apply.png";
import documentImage from "../assets/document.png";
import passengerHero from "../assets/passenger.jpg";
import rideImage from "../assets/ride.png";
import rideEarnImage from "../assets/ride_earn.png";
import scheduleImage from "../assets/schedule.png";
import walletImage from "../assets/wallet.png";

const benefits = [
  {
    title: "Ride and earn when you like",
    description:
      "Earn during evenings and weekends, or make more money by riding more frequently. It is up to you.",
    Icon: CalendarClock,
    image: rideEarnImage,
    imageAlt: "Josi rider earning on a bike",
  },
  {
    title: "A reliable source of earnings",
    description:
      "Receive orders from Josi customers and partner businesses whenever you are online.",
    Icon: WalletCards,
    image: scheduleImage,
    imageAlt: "Schedule calendar with clock",
  },
  {
    title: "Transparent weekly payouts",
    description:
      "Get your net earnings at the end of each week, excluding the agreed service fee.",
    Icon: CircleDollarSign,
    image: walletImage,
    imageAlt: "Wallet with coins",
  },
];

const steps = [
  {
    label: "Step 1.",
    title: "Register online",
    description:
      "Create your rider profile, add your contact details, and choose the city where you want to ride.",
    image: applyImage,
    imageAlt: "Phone screen showing rider application code",
  },
  {
    label: "Step 2.",
    title: "Upload your documents",
    description:
      "Add a photo of your valid ID, rider permit, or any document required for your vehicle type.",
    image: documentImage,
    imageAlt: "Approved rider document profile",
  },
  {
    label: "Step 3.",
    title: "Start riding",
    description:
      "Once approved, go online in the Josi app and start accepting ride or delivery requests.",
    image: rideImage,
    imageAlt: "Red and white scooter ready to ride",
  },
];

const appSteps = [
  "Accept a request and view the pickup details.",
  "Use the in-app navigation to reach the pickup location.",
  "Complete the ride or delivery and follow local traffic rules.",
  "Repeat to earn more money on your schedule.",
];

const faqs = [
  {
    question: "Can I ride with Josi in my city?",
    answer:
      "If Josi is active in your city, you can register and we will guide you through the local onboarding process.",
  },
  {
    question: "How do I start riding with Josi?",
    answer:
      "Complete the online form, upload your documents, and wait for an onboarding confirmation from the Josi team.",
  },
  {
    question: "What if I do not have a vehicle?",
    answer:
      "You can still register your interest. Josi may connect eligible riders with fleet owners or rental partners.",
  },
  {
    question: "What are the smartphone requirements?",
    answer:
      "Use a smartphone that supports location services, mobile data, and the latest Josi rider app.",
  },
  {
    question: "When do I get my earnings?",
    answer:
      "Earnings are reviewed weekly and paid according to your rider agreement and selected payout method.",
  },
];

function ImagePlaceholder({ label, className = "", children }) {
  return (
    <div
      className={`grid place-items-center overflow-hidden rounded-lg border border-dashed border-josi-red/35 bg-[linear-gradient(135deg,#fff,#f3f3f3)] text-center ${className}`}
    >
      <div className="grid justify-items-center gap-3 px-5 text-josi-red/70">
        {children && <span className="text-josi-red">{children}</span>}
        <span className="text-sm font-extrabold uppercase tracking-normal">
          {label}
        </span>
      </div>
    </div>
  );
}

function RiderSignupForm() {
  return (
    <form className="rounded-lg bg-white p-5 shadow-menu sm:p-6">
      <h2 className="font-display text-2xl font-bold text-ink">
        Become a rider
      </h2>

      <div className="mt-5 grid gap-4">
        <label className="grid gap-2">
          <span className="text-xs font-extrabold text-muted">Email address</span>
          <input
            className="focus-ring h-12 rounded-lg border border-line bg-paper px-4 font-normal text-ink"
            placeholder="Enter email address"
            type="email"
          />
        </label>

        <label className="grid gap-2">
          <span className="text-xs font-extrabold text-muted">Phone number</span>
          <div className="grid grid-cols-[6rem_1fr] gap-3">
            <select className="focus-ring h-12 rounded-lg border border-line bg-paper text-black px-3 font-normal">
              <option>+234</option>
            </select>
            <input
              className="focus-ring h-12 rounded-lg border border-line bg-paper px-4 font-normal text-ink"
              placeholder="Enter phone number"
              type="tel"
            />
          </div>
        </label>

        <label className="grid gap-2">
          <span className="text-xs font-extrabold text-muted">City</span>
          <select className="focus-ring h-12 rounded-lg border border-line bg-paper px-4 font-normal text-ink">
            <option value="abuja">Abuja</option>
            <option value="nasarawa">Nasarawa</option>
          </select>
        </label>

        <label className="flex items-start gap-3 text-xs font-semibold leading-relaxed text-muted">
          <input
            className="mt-1 size-4 accent-josi-red"
            type="checkbox"
            defaultChecked
          />
          <span>
            I agree to Josi contacting me with updates about rider onboarding,
            safety checks, and account setup.
          </span>
        </label>
      </div>

      <Button type="submit" variant="red" className="mt-5 w-full">
        Register as a rider
      </Button>

      <p className="mt-4 text-center text-xs font-semibold text-muted">
        Already have an account?{" "}
        <a href="#faq" className="font-extrabold text-josi-red">
          Log in
        </a>
      </p>
    </form>
  );
}

function BenefitCard({ benefit }) {
  const { Icon } = benefit;

  return (
    <article className="rounded-lg bg-white p-4 shadow-soft sm:p-5">
      <div className="aspect-[1.95/1] overflow-hidden rounded-lg bg-paper">
        <img
          src={benefit.image}
          alt={benefit.imageAlt}
          className="h-full w-full object-cover object-center"
          loading="lazy"
        />
      </div>
      <div className="mt-5 flex items-start gap-3">
        <span className="grid size-10 shrink-0 place-items-center rounded-full bg-josi-red text-white">
          <Icon size={21} />
        </span>
        <div>
          <h3 className="text-lg font-extrabold">{benefit.title}</h3>
          <p className="mt-2 text-sm font-medium leading-relaxed text-muted">
            {benefit.description}
          </p>
        </div>
      </div>
    </article>
  );
}

function StepCard({ step }) {
  return (
    <article className="rounded-lg bg-white p-4 shadow-soft sm:p-5">
      <div className="aspect-[1.95/1] overflow-hidden rounded-lg bg-white shadow-soft">
        <img
          src={step.image}
          alt={step.imageAlt}
          className="h-full w-full object-cover object-center"
          loading="lazy"
        />
      </div>
      <p className="mt-5 text-xs font-extrabold text-muted">{step.label}</p>
      <h3 className="mt-2 text-lg font-extrabold">{step.title}</h3>
      <p className="mt-2 text-sm font-medium leading-relaxed text-muted">
        {step.description}
      </p>
    </article>
  );
}

function RiderAppPreview() {
  return (
    <div className="mx-auto w-full max-w-[18rem] rounded-[2.5rem] border-[0.75rem] border-ink bg-white p-3 shadow-soft">
      <div className="mx-auto mb-3 h-5 w-24 rounded-full bg-ink" />
      <ImagePlaceholder
        label="App image placeholder"
        className="aspect-[9/16] rounded-[1.7rem]"
      />
    </div>
  );
}

function FaqItem({ item, isOpen, onClick }) {
  return (
    <div className="rounded-lg bg-white shadow-soft">
      <button
        type="button"
        className="focus-ring flex w-full items-center justify-between gap-4 px-5 py-5 text-left"
        onClick={onClick}
        aria-expanded={isOpen}
      >
        <span className="text-base font-extrabold text-ink">{item.question}</span>
        {isOpen ? <Minus size={18} /> : <Plus size={18} />}
      </button>
      {isOpen && (
        <p className="px-5 pb-5 text-sm font-medium leading-relaxed text-muted">
          {item.answer}
        </p>
      )}
    </div>
  );
}

export default function RiderPage() {
  const [openFaq, setOpenFaq] = useState(0);

  return (
    <main className="bg-[#f4f6f5]">
      <section className="relative overflow-hidden bg-josi-black text-white">
        <div className="absolute inset-0">
          <img
            src={passengerHero}
            alt=""
            className="h-full w-full object-cover object-[62%_center]"
          />
          <div className="absolute inset-0 bg-[linear-gradient(90deg,rgba(0,0,0,0.9)_0%,rgba(0,0,0,0.64)_48%,rgba(0,0,0,0.22)_100%)]" />
          <div className="absolute inset-0 bg-josi-red/10" />
        </div>
        <div className="section-shell relative grid gap-8 py-10 sm:py-14 lg:grid-cols-[1fr_25rem] lg:items-center lg:py-20">
          <div className="max-w-2xl">
            <h1 className="font-display text-[2rem] font-bold leading-[1.02] sm:text-6xl lg:text-[3rem]">
              Make money riding with Josi
            </h1>
            <p className="mt-5 max-w-xl text-base font-semibold leading-relaxed text-white/85 sm:text-lg">
              Become a Josi rider partner, set your schedule, and earn money
              moving people and packages across your city.
            </p>
          </div>

          <RiderSignupForm />
        </div>
      </section>

      <section className="py-12 sm:py-16 lg:py-20">
        <div className="section-shell">
          <h2 className="font-display text-3xl font-bold leading-tight sm:text-5xl">
            Why become a Josi rider?
          </h2>
          <p className="mt-4 max-w-3xl text-base font-medium leading-relaxed text-muted">
            Whether you want to ride for a few hours occasionally or earn more
            frequently, Josi can fit around your schedule.
          </p>

          <div className="mt-9 grid gap-8 md:grid-cols-3">
            {benefits.map((benefit) => (
              <BenefitCard key={benefit.title} benefit={benefit} />
            ))}
          </div>
        </div>
      </section>

      <section className="py-12 sm:py-16 lg:py-20">
        <div className="section-shell">
          <h2 className="font-display text-3xl font-bold leading-tight sm:text-5xl">
            Get started
          </h2>
          <p className="mt-4 max-w-3xl text-base font-medium leading-relaxed text-muted">
            Register online, upload your documents, and start accepting requests
            once your rider account is approved.
          </p>

          <div className="mt-9 grid gap-8 md:grid-cols-3">
            {steps.map((step) => (
              <StepCard key={step.title} step={step} />
            ))}
          </div>

          <Button variant="red" className="mt-8" to="/become-a-rider">
            Apply to ride
          </Button>
        </div>
      </section>

      <section className="bg-white py-12 sm:py-16 lg:py-20">
        <div className="section-shell grid items-center gap-10 lg:grid-cols-2 lg:gap-16">
          <RiderAppPreview />
          <div>
            <h2 className="font-display text-3xl font-bold leading-tight sm:text-5xl">
              How the Josi Rider app works
            </h2>
            <p className="mt-4 max-w-xl text-base font-medium leading-relaxed text-muted">
              Reliable and easy to use, with everything you need to ride and
              earn when you want.
            </p>
            <div className="mt-7 grid gap-4">
              {appSteps.map((step) => (
                <div key={step} className="grid grid-cols-[1.75rem_1fr] gap-3">
                  <CheckCircle2 size={20} className="mt-0.5 text-josi-red" />
                  <p className="text-sm font-bold leading-relaxed text-ink">
                    {step}
                  </p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      <section id="faq" className="py-12 sm:py-16 lg:py-20">
        <div className="section-shell">
          <h2 className="max-w-2xl font-display text-2xl font-bold leading-tight sm:text-4xl">
            Frequently asked questions from riders
          </h2>
          <div className="mt-8 grid gap-4">
            {faqs.map((item, index) => (
              <FaqItem
                key={item.question}
                item={item}
                isOpen={openFaq === index}
                onClick={() =>
                  setOpenFaq((current) => (current === index ? -1 : index))
                }
              />
            ))}
          </div>
        </div>
      </section>
    </main>
  );
}
