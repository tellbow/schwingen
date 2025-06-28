export interface OrganizationData {
  name: string;
  url: string;
  logo?: string;
  description?: string;
}

export interface PersonData {
  name: string;
  givenName?: string;
  familyName?: string;
  url?: string;
  jobTitle?: string;
  worksFor?: OrganizationData;
}

export interface EventData {
  name: string;
  startDate: string;
  endDate?: string;
  location: {
    name: string;
    address?: string;
  };
  description?: string;
  organizer?: OrganizationData;
}

export interface WebSiteData {
  name: string;
  url: string;
  description: string;
  publisher: OrganizationData;
}

export interface BreadcrumbData {
  name: string;
  url: string;
}

export const useStructuredData = () => {
  const config = useRuntimeConfig();

  const createOrganization = (data: OrganizationData) => ({
    "@type": "Organization",
    "@id": `${config.public.baseUrl}/#organization`,
    name: data.name,
    url: data.url,
    ...(data.logo && { logo: data.logo }),
    ...(data.description && { description: data.description }),
  });

  const createPerson = (data: PersonData) => ({
    "@type": "Person",
    "@id": data.url ? `${data.url}#person` : `${config.public.baseUrl}/#person`,
    name: data.name,
    ...(data.givenName && { givenName: data.givenName }),
    ...(data.familyName && { familyName: data.familyName }),
    ...(data.url && { url: data.url }),
    ...(data.jobTitle && { jobTitle: data.jobTitle }),
    ...(data.worksFor && { worksFor: createOrganization(data.worksFor) }),
  });

  const createEvent = (data: EventData) => ({
    "@type": "SportsEvent",
    "@id": `${config.public.baseUrl}/#event`,
    name: data.name,
    startDate: data.startDate,
    ...(data.endDate && { endDate: data.endDate }),
    location: {
      "@type": "Place",
      name: data.location.name,
      ...(data.location.address && { address: data.location.address }),
    },
    ...(data.description && { description: data.description }),
    ...(data.organizer && { organizer: createOrganization(data.organizer) }),
  });

  const createWebSite = (data: WebSiteData) => ({
    "@type": "WebSite",
    "@id": `${config.public.baseUrl}/#website`,
    name: data.name,
    url: data.url,
    description: data.description,
    publisher: createOrganization(data.publisher),
  });

  const createBreadcrumbList = (breadcrumbs: BreadcrumbData[]) => ({
    "@type": "BreadcrumbList",
    "@id": `${config.public.baseUrl}/#breadcrumb`,
    itemListElement: breadcrumbs.map((breadcrumb, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: breadcrumb.name,
      item: breadcrumb.url,
    })),
  });

  const createSportsOrganization = (data: OrganizationData) => ({
    "@type": "SportsOrganization",
    "@id": `${config.public.baseUrl}/#sports-organization`,
    name: data.name,
    url: data.url,
    ...(data.logo && { logo: data.logo }),
    ...(data.description && { description: data.description }),
  });

  const createAthlete = (data: PersonData) => ({
    "@type": "Athlete",
    "@id": data.url
      ? `${data.url}#athlete`
      : `${config.public.baseUrl}/#athlete`,
    name: data.name,
    ...(data.givenName && { givenName: data.givenName }),
    ...(data.familyName && { familyName: data.familyName }),
    ...(data.url && { url: data.url }),
    ...(data.worksFor && { memberOf: createSportsOrganization(data.worksFor) }),
  });

  const setStructuredData = (data: any) => {
    useHead({
      script: [
        {
          type: "application/ld+json",
          innerHTML: JSON.stringify(data),
        },
      ],
    });
  };

  return {
    createOrganization,
    createPerson,
    createEvent,
    createWebSite,
    createBreadcrumbList,
    createSportsOrganization,
    createAthlete,
    setStructuredData,
  };
};
