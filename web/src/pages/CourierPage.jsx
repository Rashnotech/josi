import { useRef, useState } from "react";
import {
  Banknote,
  Bike,
  BriefcaseBusiness,
  CalendarClock,
  ChevronLeft,
  ChevronRight,
  CheckCircle2,
  CircleDollarSign,
  Clock3,
  CreditCard,
  FileCheck2,
  IdCard,
  MapPinned,
  Minus,
  PackageCheck,
  Phone,
  Plus,
  ShieldCheck,
  Smartphone,
  Star,
  WalletCards,
} from "lucide-react";
import Button from "../components/Button.jsx";
import AuthRegistrationForm from "../components/AuthRegistrationForm.jsx";
import applyImage from "../assets/apply.png";
import bikesLifestyle from "../assets/bikes.png";
import documentImage from "../assets/document.png";
import holderPackageImage from "../assets/holder-package.jpg";
import michaelImage from "../assets/michael.jpg";
import moneyImage from "../assets/money.png";
import rideImage from "../assets/ride.png";
import rideEarnImage from "../assets/ride_earn.png";
import scheduleImage from "../assets/schedule.png";
import scooterFeature from "../assets/scooter.png";
import walletImage from "../assets/wallet.png";
import waybillHero from "../assets/waybill.png";
import Scooter from "../assets/scooter.png";

const freedomItems = [
  {
    title: "Fair earnings and fair prices",
    description:
      "Earn more when you deliver during busy hours, peak zones, and high-demand periods.",
    Icon: CircleDollarSign,
  },
  {
    title: "Flexible schedule",
    description:
      "Deliver on your terms, with either a part-time, full-time, or occasional schedule.",
    Icon: CalendarClock,
  },
  {
    title: "Earn more when it is busy",
    description:
      "During peak hours, local orders, and high-demand zones, Josi helps you earn more.",
    Icon: Clock3,
  },
  {
    title: "Earn more tips",
    description:
      "Customers who value great service can tip directly through the app.",
    Icon: Banknote,
  },
  {
    title: "24/7 support",
    description:
      "If you need help on the road, our support team is available whenever you are delivering.",
    Icon: ShieldCheck,
  },
  {
    title: "Clear delivery details",
    description:
      "Pickup, drop-off, and customer notes are shown clearly before and during each trip.",
    Icon: MapPinned,
  },
];

const stories = [
  {
    name: "Micheal, Lagos",
    quote:
      "Josi gives me the flexibility to deliver around my schedule and still keep track of my weekly earnings.",
    image: michaelImage,
    imageAlt: "Micheal courier partner",
  },
  {
    name: "Victor, Abuja",
    quote:
      "The app makes delivery requests simple. I can see where to pick up, where to go, and how much I am earning.",
    image: holderPackageImage,
    imageAlt: "Victor holding a delivery package",
  },
];

const earnings = [
  {
    title: "Base pay",
    description:
      "Every order includes a starting amount based on pickup, drop-off, and estimated effort.",
    Icon: WalletCards,
    image: moneyImage,
    imageAlt: "Courier earnings money",
  },
  {
    title: "Distance",
    description:
      "The ride distance between pickup and drop-off can increase your delivery earnings.",
    Icon: Bike,
    image: rideEarnImage,
    imageAlt: "Courier riding for delivery earnings",
  },
  {
    title: "Time",
    description:
      "If a delivery takes longer because of waiting or traffic, your earnings can reflect it.",
    Icon: Clock3,
    image: scheduleImage,
    imageAlt: "Courier schedule and time earnings",
  },
  {
    title: "Bonuses",
    description:
      "Josi can add incentives for selected zones, order types, or busy periods.",
    Icon: Star,
    image: walletImage,
    imageAlt: "Courier bonus wallet earnings",
  },
];

const requirements = [
  {
    title: "A valid photo ID",
    description: "To prove your identity and support account verification.",
    Icon: IdCard,
    image: documentImage,
    imageAlt: "Courier identity document",
  },
  {
    title: "A smartphone",
    description: "Android or iOS with location, mobile data, and the Josi app.",
    Icon: Smartphone,
    image: applyImage,
    imageAlt: "Courier applying with a smartphone",
  },
  {
    title: "A bike, scooter, or car",
    description: "Use your preferred delivery vehicle where it is allowed.",
    Icon: Bike,
    image: rideImage,
    imageAlt: "Courier delivery ride",
  },
  {
    title: "A bank account",
    description: "To receive your weekly earnings safely and directly.",
    Icon: CreditCard,
    image: walletImage,
    imageAlt: "Courier payout wallet",
  },
];

const steps = [
  {
    label: "Step 1.",
    title: "Register to deliver",
    description:
      "Enter your name, city, phone number, and preferred delivery mode.",
    Icon: Phone,
    image: applyImage,
    imageAlt: "Courier registration application",
  },
  {
    label: "Step 2.",
    title: "Upload your documents",
    description:
      "Submit your ID and any local documents required for your delivery vehicle.",
    Icon: FileCheck2,
    image: documentImage,
    imageAlt: "Courier document upload",
  },
  {
    label: "Step 3.",
    title: "Get your delivery kit",
    description:
      "Pick up or request your delivery bag and materials after approval.",
    Icon: PackageCheck,
    image: rideEarnImage,
    imageAlt: "Courier rider ready to earn",
  },
  {
    label: "Step 4.",
    title: "Start earning",
    description:
      "Go online, accept orders, and deliver across your city with Josi.",
    Icon: Bike,
    image: moneyImage,
    imageAlt: "Courier earnings payout",
  },
];

const faqs = [
  {
    question: "How do I become a Josi courier partner?",
    answer:
      "Register online, upload your documents, and complete any local onboarding steps required in your city.",
  },
  {
    question: "How do I register?",
    answer:
      "Use the form on this page. A Josi onboarding team member will follow up with next steps.",
  },
  {
    question: "Where can I pick up deliveries?",
    answer:
      "You will see available pickup points and partner locations inside the Josi courier app.",
  },
  {
    question: "Do I need a delivery bag?",
    answer:
      "Some order types require an insulated delivery bag. Josi will tell you what is needed during onboarding.",
  },
  {
    question: "How much can I earn with Josi Food?",
    answer:
      "Earnings depend on order volume, distance, time, tips, and available bonuses in your delivery area.",
  },
  {
    question: "How do I get paid?",
    answer:
      "Your earnings are paid to the bank account you add during registration, based on the payout schedule.",
  },
];

function ImagePlaceholder({ label, className = "", children }) {
  return (
    <div
      className={`grid place-items-center overflow-hidden rounded-lg border border-dashed border-josi-red/35 bg-[linear-gradient(135deg,#101010,#31090b_58%,#f5f5f5)] text-center ${className}`}
    >
      <div className="grid justify-items-center gap-3 px-5 text-white">
        {children && <span className="text-josi-red">{children}</span>}
        <span className="text-xs font-extrabold uppercase tracking-normal text-white/80">
          {label}
        </span>
      </div>
    </div>
  );
}

function CardImage({ src, alt, className = "", children }) {
  return (
    <div className={`relative overflow-hidden rounded-lg bg-paper ${className}`}>
      <img
        src={src}
        alt={alt}
        loading="lazy"
        className="h-full w-full object-cover object-center"
      />
      {children}
    </div>
  );
}

function MobileCardCarousel({
  children,
  className = "",
  controlsTheme = "light",
  ariaLabel,
}) {
  const scrollerRef = useRef(null);
  const isDark = controlsTheme === "dark";

  const moveCards = (direction) => {
    const scroller = scrollerRef.current;

    if (!scroller) {
      return;
    }

    const firstCard = scroller.firstElementChild;
    const styles = window.getComputedStyle(scroller);
    const gap =
      Number.parseFloat(styles.columnGap || styles.gap || "16") || 16;
    const cardWidth =
      firstCard?.getBoundingClientRect().width || scroller.clientWidth * 0.82;

    scroller.scrollBy({
      left: direction * (cardWidth + gap),
      behavior: "smooth",
    });
  };

  const buttonClass = isDark
    ? "bg-white text-ink hover:bg-white/90"
    : "bg-josi-black text-white hover:bg-ink";

  return (
    <div className="mt-9">
      <div
        ref={scrollerRef}
        className={`-mx-5 flex gap-4 overflow-x-hidden scroll-smooth px-5 pb-1 sm:mx-0 sm:overflow-visible sm:px-0 ${className}`}
      >
        {children}
      </div>

      <div className="mt-5 flex justify-center gap-3 sm:hidden">
        <button
          type="button"
          className={`focus-ring grid size-11 place-items-center rounded-full shadow-soft transition ${buttonClass}`}
          onClick={() => moveCards(-1)}
          aria-label={`Show previous ${ariaLabel}`}
        >
          <ChevronLeft size={20} />
        </button>
        <button
          type="button"
          className={`focus-ring grid size-11 place-items-center rounded-full shadow-soft transition ${buttonClass}`}
          onClick={() => moveCards(1)}
          aria-label={`Show next ${ariaLabel}`}
        >
          <ChevronRight size={20} />
        </button>
      </div>
    </div>
  );
}

function CourierSignupForm() {
  return (
    <div className="w-full min-w-0">
      <AuthRegistrationForm
        role="courier"
        title="Start delivering with Josi"
        submitLabel="Register now"
      />
    </div>
  );
}

function FreedomItem({ item }) {
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

function StoryCard({ story }) {
  return (
    <article className="overflow-hidden rounded-lg bg-white/5 ring-1 ring-white/10">
      <img
        src={story.image}
        alt={story.imageAlt}
        loading="lazy"
        className="aspect-[1.35/1] w-full object-cover object-center"
      />
      <div className="p-5">
        <h3 className="text-lg font-extrabold text-white">{story.name}</h3>
        <p className="mt-3 text-sm font-medium leading-relaxed text-white/70">
          {story.quote}
        </p>
      </div>
    </article>
  );
}

function EarningsCard({ item }) {
  const { Icon } = item;

  return (
    <article className="min-w-[15rem] rounded-lg bg-white p-5 shadow-soft">
      <span className="grid size-9 place-items-center rounded-full bg-ink text-white">
        <Icon size={18} />
      </span>
      <h3 className="mt-5 text-lg font-extrabold">{item.title}</h3>
      <p className="mt-2 text-sm font-medium leading-relaxed text-muted">
        {item.description}
      </p>
      <CardImage
        src={item.image}
        alt={item.imageAlt}
        className="mt-5 aspect-[1.25/1]"
      />
    </article>
  );
}

function RequirementCard({ item, dark = false }) {
  const { Icon } = item;

  return (
    <article
      className={`rounded-lg p-5 ${
        dark ? "bg-josi-black text-white" : "bg-white text-ink"
      }`}
    >
      <div className="flex items-start justify-between gap-4">
        <div>
          <h3 className="text-lg font-extrabold">{item.title}</h3>
          <p
            className={`mt-2 text-sm font-medium leading-relaxed ${
              dark ? "text-white/70" : "text-muted"
            }`}
          >
            {item.description}
          </p>
        </div>
        <span className="grid size-10 shrink-0 place-items-center rounded-full bg-josi-red text-white">
          <Icon size={19} />
        </span>
      </div>
      <CardImage
        src={item.image}
        alt={item.imageAlt}
        className="mt-5 aspect-[1.65/1]"
      />
    </article>
  );
}

function StepCard({ step }) {
  const { Icon } = step;

  return (
    <article className="min-w-[15.5rem] rounded-lg bg-white/5 p-5 ring-1 ring-white/10">
      <CardImage
        src={step.image}
        alt={step.imageAlt}
        className="aspect-[1.45/1]"
      >
        <span className="absolute right-3 top-3 grid size-9 place-items-center rounded-full bg-josi-red text-white shadow-soft">
          <Icon size={18} />
        </span>
      </CardImage>
      <p className="mt-5 text-xs font-extrabold text-white/50">{step.label}</p>
      <h3 className="mt-2 text-lg font-extrabold text-white">{step.title}</h3>
      <p className="mt-2 text-sm font-medium leading-relaxed text-white/68">
        {step.description}
      </p>
    </article>
  );
}

function FaqItem({ item, isOpen, onClick }) {
  return (
    <div className="rounded-lg bg-black ring-1 ring-white/10">
      <button
        type="button"
        className="focus-ring flex w-full items-center justify-between gap-4 px-5 py-5 text-left"
        onClick={onClick}
        aria-expanded={isOpen}
      >
        <span className="text-sm font-extrabold text-white sm:text-base">
          {item.question}
        </span>
        {isOpen ? (
          <Minus size={18} className="text-white" />
        ) : (
          <Plus size={18} className="text-white" />
        )}
      </button>
      {isOpen && (
        <p className="px-5 pb-5 text-sm font-medium leading-relaxed text-white/65">
          {item.answer}
        </p>
      )}
    </div>
  );
}

export default function CourierPage() {
  const [openFaq, setOpenFaq] = useState(0);

  return (
    <main className="bg-[#f4f6f5]">
      <section className="relative overflow-hidden bg-josi-black text-white">
        <div className="absolute inset-0">
          <img
            src={waybillHero}
            alt=""
            className="h-full w-full object-cover object-[58%_center]"
          />
          <div className="absolute inset-0 bg-[linear-gradient(90deg,rgba(0,0,0,0.88)_0%,rgba(0,0,0,0.62)_48%,rgba(0,0,0,0.22)_100%)]" />
          <div className="absolute inset-0 bg-josi-red/10" />
        </div>

        <div className="section-shell relative grid min-w-0 gap-8 py-10 sm:py-14 lg:grid-cols-[minmax(0,1fr)_minmax(22rem,26rem)] lg:items-center lg:py-20">
          <div className="max-w-2xl">
            <h1 className="font-display text-[2.3rem] font-bold leading-[1.04] sm:text-6xl lg:text-[3.25rem]">
              Become a courier rider and deliver on your terms
            </h1>
            <p className="mt-5 max-w-xl text-base font-semibold leading-relaxed text-white/82 sm:text-lg">
              Choose when you deliver, receive fair payouts, and start earning
              with Josi across your city.
            </p>
          </div>

          <CourierSignupForm />
        </div>
      </section>

      <section className="bg-[#03110d] py-12 text-white sm:py-16">
        <div className="section-shell text-center">
          <p className="mx-auto max-w-3xl font-display text-3xl font-bold leading-tight sm:text-5xl">
            Trusted by courier partners across Nigeria
          </p>
          <p className="mx-auto mt-4 max-w-2xl text-sm font-semibold leading-relaxed text-white/68 sm:text-base">
            Josi supports flexible delivery work for riders who want reliable
            local movement, clear earnings, and practical onboarding.
          </p>
        </div>
      </section>

      <section className="py-12 sm:py-16 lg:py-20">
        <div className="section-shell">
          <h2 className="font-display text-3xl font-bold leading-tight sm:text-5xl">
            Freedom to earn your way
          </h2>
          <p className="mt-4 max-w-3xl text-base font-medium leading-relaxed text-muted">
            Whether you deliver during lunch rush, after work, or full-time,
            Josi gives you the flexibility to move at your pace.
          </p>

          <div className="mt-9 grid gap-8 sm:grid-cols-2 lg:grid-cols-3">
            {freedomItems.map((item) => (
              <FreedomItem key={item.title} item={item} />
            ))}
          </div>
        </div>
      </section>

      <section className="bg-[#03110d] py-12 sm:py-16 lg:py-20">
        <div className="section-shell">
          <h2 className="font-display text-3xl font-bold leading-tight text-white sm:text-5xl">
            Real stories from courier partners
          </h2>
          <div className="mt-8 grid gap-5 md:grid-cols-2">
            {stories.map((story) => (
              <StoryCard key={story.name} story={story} />
            ))}
          </div>
        </div>
      </section>

      <section className="py-12 sm:py-16 lg:py-20">
        <div className="section-shell">
          <p className="text-center text-xs font-extrabold uppercase text-muted">
            Earnings
          </p>
          <h2 className="mx-auto mt-3 max-w-2xl text-center font-display text-3xl font-bold leading-tight sm:text-5xl">
            How your earnings are calculated
          </h2>
          <p className="mx-auto mt-4 max-w-3xl text-center text-base font-medium leading-relaxed text-muted">
            Earnings can depend on base pay, delivery distance, time, tips, and
            bonuses. The exact amount is shown in the Josi app before you
            accept eligible orders.
          </p>

          <MobileCardCarousel
            ariaLabel="earning cards"
            className="sm:grid sm:grid-cols-2 lg:grid-cols-4"
          >
            {earnings.map((item) => (
              <EarningsCard key={item.title} item={item} />
            ))}
          </MobileCardCarousel>
        </div>
      </section>

      <section className="py-12 sm:py-16 lg:py-20">
        <div className="section-shell">
          <p className="text-center text-xs font-extrabold uppercase text-muted">
            Requirements
          </p>
          <h2 className="mx-auto mt-3 max-w-2xl text-center font-display text-3xl font-bold leading-tight sm:text-5xl">
            What you need to get started
          </h2>
          <p className="mx-auto mt-4 max-w-3xl text-center text-base font-medium leading-relaxed text-muted">
            Registration is simple. Verify your identity, confirm your payout
            details, and use a delivery mode that works in your city.
          </p>

          <div className="mt-9 grid gap-4 md:grid-cols-2">
            {requirements.map((item, index) => (
              <RequirementCard
                key={item.title}
                item={item}
                dark={index === 2}
              />
            ))}
          </div>
        </div>
      </section>

      <section className="bg-[#03110d] py-12 sm:py-16 lg:py-20">
        <div className="section-shell">
          <h2 className="mx-auto max-w-2xl text-center font-display text-3xl font-bold leading-tight text-white sm:text-5xl">
            Four easy steps to start delivering
          </h2>
          <p className="mx-auto mt-4 max-w-2xl text-white text-center text-sm font-semibold leading-relaxed text-white/68">
            You are ready to earn when your profile is approved and your
            delivery mode is verified.
          </p>

          <MobileCardCarousel
            ariaLabel="delivery steps"
            controlsTheme="dark"
            className="text-white sm:grid sm:grid-cols-2 lg:grid-cols-4"
          >
            {steps.map((step) => (
              <StepCard key={step.title} step={step} />
            ))}
          </MobileCardCarousel>
        </div>
      </section>

      <section className="bg-white py-12 sm:py-16">
        <div className="section-shell text-center">
          <h2 className="mx-auto max-w-2xl font-display text-3xl font-bold leading-tight sm:text-5xl">
            Join courier partners earning with Josi
          </h2>
          <p className="mx-auto mt-4 max-w-2xl text-base font-medium leading-relaxed text-muted">
            Deliver packages, food, and business orders with a platform designed
            for everyday city movement.
          </p>
          <Button variant="red" to="/become-a-courier" className="mt-7">
            Start earning
          </Button>
        </div>
      </section>

      <div className="mx-auto h-64 max-w-6xl overflow-hidden rounded-none bg-josi-black sm:h-96 lg:rounded-lg">
        <img
          src={bikesLifestyle}
          alt="Josi branded bikes ready for courier movement"
          className="h-full w-full object-cover object-center"
          loading="lazy"
        />
      </div>

      <section id="courier-faq" className="bg-[#0b0d0c] py-12 sm:py-16 lg:py-20">
        <div className="section-shell">
          <h2 className="mx-auto max-w-2xl text-center font-display text-3xl font-bold leading-tight text-white sm:text-5xl">
            Frequently asked questions
          </h2>
          <p className="mx-auto mt-4 max-w-2xl text-center text-sm font-semibold leading-relaxed text-white/62">
            We are here to support your courier onboarding.
          </p>

          <div className="mx-auto mt-8 grid max-w-4xl gap-3">
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
