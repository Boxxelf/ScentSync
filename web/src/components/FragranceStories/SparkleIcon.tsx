export function SparkleIcon({ className, ...props }: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      aria-hidden="true"
      {...props}
    >
      <path
        d="M12 2.5 14 7l4.5 2-4.5 2L12 15l-2-4-4.5-2L10 7l2-4.5Z"
        stroke="url(#sparkle-gradient)"
        strokeWidth="1.2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="m6.5 17 1 2.5 2.5 1-2.5 1-1 2.5-1-2.5-2.5-1 2.5-1 1-2.5Z"
        stroke="url(#sparkle-gradient)"
        strokeWidth="0.9"
        strokeLinecap="round"
        strokeLinejoin="round"
        opacity="0.6"
      />
      <path
        d="m16.5 17 0.8 2 2 0.8-2 0.8-0.8 2-0.8-2-2-0.8 2-0.8 0.8-2Z"
        stroke="url(#sparkle-gradient)"
        strokeWidth="0.9"
        strokeLinecap="round"
        strokeLinejoin="round"
        opacity="0.5"
      />
      <defs>
        <linearGradient
          id="sparkle-gradient"
          x1="4"
          y1="2.5"
          x2="20"
          y2="22"
          gradientUnits="userSpaceOnUse"
        >
          <stop offset="0" stopColor="#f6c8ff" />
          <stop offset="1" stopColor="#fdd8af" />
        </linearGradient>
      </defs>
    </svg>
  );
}

