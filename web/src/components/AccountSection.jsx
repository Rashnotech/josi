import Button from "./Button.jsx";
import deliverImage from "../assets/deliver.jpg";

export default function AccountSection() {
  return (
    <section id="account" className="bg-white py-12 sm:py-16">
      <div className="section-shell grid items-center gap-8 md:grid-cols-2 md:gap-14">
        <div className="max-w-lg">
          <h2 className="font-display text-3xl font-bold leading-tight sm:text-4xl">
            Log in to see your account details
          </h2>
          <p className="mt-5 max-w-md text-base font-medium leading-relaxed text-muted">
            View past trips, tailored suggestions, support resources, and more
            from your Josi account.
          </p>
          <div className="mt-6 flex flex-wrap items-center gap-4">
            <Button to="/login">Log in to your account</Button>
            <Button to="/become-a-rider" variant="light">
              Create an account
            </Button>
          </div>
        </div>
        <div className="aspect-[1.15/1] overflow-hidden rounded-lg bg-paper shadow-soft">
          <img
            src={deliverImage}
            alt="Delivery rider on a scooter"
            className="h-full w-full object-cover object-center"
            loading="lazy"
          />
        </div>
      </div>
    </section>
  );
}
