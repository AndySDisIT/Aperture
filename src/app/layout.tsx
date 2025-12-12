import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Aperture - Open Your Aperture",
  description: "Where gay and bi men control their visibility and connection",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
