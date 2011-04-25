#ifndef _WIN_H_
#define _WIN_H_

IMAGE_SECTION_HEADER* GetEnclosingSectionHeader(unsigned long rva, IMAGE_NT_HEADERS32* pNTHeader);
void* GetPtrFromRVA(unsigned long rva, IMAGE_NT_HEADERS32* pNTHeader, unsigned char* imageBase);
void DumpDllFromPath(VALUE mDeps, char* path);

#endif /* _WIN_H_ */
