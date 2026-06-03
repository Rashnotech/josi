import { ArrowRight, Smartphone } from "lucide-react";

function QrMock() {
  return (
    <div className="grid size-24 grid-cols-9 grid-rows-9 gap-1 bg-white p-2">
      {Array.from({ length: 81 }).map((_, index) => (
        <span key={index} className="qr-cell rounded-[1px] bg-transparent" />
      ))}
    </div>
  );
}

const appCards = [
  { title: "Download the Josi app", description: "Scan to download" },
  { title: "Download the Rider app", description: "Scan to download" },
];

export default function AppsSection() {
  return (
    <section className="bg-paper py-12 sm:py-16">
      <div className="section-shell">
        <h2 className="font-display text-3xl font-bold sm:text-4xl">
          It is easier in the apps
        </h2>
        <div className="mt-6 grid gap-5 md:grid-cols-2">
          {appCards.map((card) => (
            <article
              key={card.title}
              className="grid grid-cols-[auto_1fr_auto] items-center gap-5 rounded-lg bg-white p-4 sm:p-6"
            >
              <QrMock />
              <div>
                <Smartphone size={20} className="mb-3 text-josi-red" />
                <h3 className="text-lg font-extrabold leading-tight">
                  {card.title}
                </h3>
                <p className="mt-1 text-sm font-semibold text-muted">
                  {card.description}
                </p>
              </div>
              <ArrowRight size={22} />
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
