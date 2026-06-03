import {
  Bike,
  CarFront,
  ChevronRight,
  Package,
  Store,
} from "lucide-react";

export const registerOptions = [
  {
    title: "Become a rider",
    description: "Make money on your terms",
    path: "/become-a-rider",
    Icon: CarFront,
  },
  {
    title: "Become a courier",
    description: "Deliver packages and get paid weekly",
    path: "/become-a-courier",
    Icon: Package,
  },
  {
    title: "Sign up as a pack owner",
    description: "Add your pack and grow your income",
    path: "/sign-up-as-a-pack-owner",
    Icon: Bike,
  }
];

export { ChevronRight, Store };
