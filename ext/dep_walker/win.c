#include <windows.h>
#include <imagehlp.h>
#include <ruby.h>

IMAGE_SECTION_HEADER* GetEnclosingSectionHeader(unsigned long rva, IMAGE_NT_HEADERS32* pNTHeader)
{
  IMAGE_SECTION_HEADER* section = IMAGE_FIRST_SECTION(pNTHeader);
  unsigned int i;

  for (i=0; i < pNTHeader->FileHeader.NumberOfSections; i++, section++)
  {
    unsigned long size = section->Misc.VirtualSize;
    if (0 == size)
    {
      size = section->SizeOfRawData;
    }

    // Is the RVA within this section?
    if ((rva >= section->VirtualAddress) &&
        (rva < (section->VirtualAddress + size)))
    {
      return section;
    }
  }

  return 0;
}

void* GetPtrFromRVA(unsigned long rva, IMAGE_NT_HEADERS32* pNTHeader, unsigned char* imageBase)
{
  IMAGE_SECTION_HEADER* pSectionHdr;
  int delta;

  pSectionHdr = GetEnclosingSectionHeader(rva, pNTHeader);
  if (!pSectionHdr)
    return 0;

  delta = (int)(pSectionHdr->VirtualAddress-pSectionHdr->PointerToRawData);
  return (void*)(imageBase + rva - delta);
}

void DumpDllFromPath(VALUE mDeps, char* path)
{
  LOADED_IMAGE* image=ImageLoad(path,0);

  if (NULL != image && image->FileHeader->OptionalHeader.NumberOfRvaAndSizes>=2) {
    IMAGE_IMPORT_DESCRIPTOR* importDesc=
      (IMAGE_IMPORT_DESCRIPTOR*)GetPtrFromRVA(
                         image->FileHeader->OptionalHeader.DataDirectory[1].VirtualAddress,
                         image->FileHeader, image->MappedAddress);
    while (1)
    {
      // See if we've reached an empty IMAGE_IMPORT_DESCRIPTOR
      if ((importDesc->TimeDateStamp==0) && (importDesc->Name==0))
        break;

      rb_ary_push(mDeps, rb_str_new2((const char*)GetPtrFromRVA(importDesc->Name,
                                                          image->FileHeader,
                                                          image->MappedAddress)));
      importDesc++;
    }
  }
  ImageUnload(image);
}
