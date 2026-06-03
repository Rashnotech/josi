import AccountSection from "../components/AccountSection.jsx";
import AppsSection from "../components/AppsSection.jsx";
import ExploreCards from "../components/ExploreCards.jsx";
import Hero from "../components/Hero.jsx";
import ReserveSection from "../components/ReserveSection.jsx";
import SplitFeature from "../components/SplitFeature.jsx";
import courierImage from "../assets/courier.png";
import scooterImage from "../assets/scooter.png";
import waybillImage from "../assets/waybill.png";

function SplitFeatureImage({ src, alt, position = "object-center" }) {
  return (
    <div className="aspect-[1.18/1] overflow-hidden rounded-lg bg-paper shadow-soft sm:aspect-[1.34/1]">
      <img
        src={src}
        alt={alt}
        className={`h-full w-full object-cover ${position}`}
        loading="lazy"
      />
    </div>
  );
}

export default function Home() {
  return (
    <main>
      <Hero />
      <div className="h-8 bg-white sm:h-12 lg:h-16" aria-hidden="true" />
      <ExploreCards />
      <AccountSection />
      <ReserveSection />
      <SplitFeature
        title="Planning your next getaway?"
        description="From weekend road trips to international destinations, Josi helps you compare transport options, points of interest, and reliable local movement."
        image={
          <SplitFeatureImage
            src={scooterImage}
            alt="Josi scooters ready for city movement"
          />
        }
        primary="Explore"
        primaryTo="/become-a-rider"
        reverse
      />
      <SplitFeature
        title="Ride when you want, make what you need"
        description="Make money on your schedule with deliveries or rides, or both. You can use your own car or choose a rental through Josi."
        image={
          <SplitFeatureImage
            src={courierImage}
            alt="Josi courier rider with delivery bag"
            position="object-[58%_center]"
          />
        }
        primary="Get started"
        primaryTo="/become-a-rider"
        secondary="Already have an account? Sign in"
        secondaryTo="/login"
        id="drive"
      />
      <SplitFeature
        title="The Josi you know, reimagined for business"
        description="Josi for Business is a platform for managing transport rides and deliveries, meal support, freight, and local movement for companies of any size."
        image={
          <SplitFeatureImage
            src={waybillImage}
            alt="Josi delivery scooters and waybill logistics"
            position="object-center"
          />
        }
        primary="Get started"
        primaryTo="/sign-up-as-a-pack-owner"
        secondary="Check out our solutions"
        secondaryTo="/become-a-courier"
        reverse
        id="business"
      />
      <AppsSection />
    </main>
  );
}
