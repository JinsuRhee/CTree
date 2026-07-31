function rdtree_mkarray, n, tag
  compile_opt idl2

  case tag of
    1l: RETURN, lonarr(n)
    2l: RETURN, lon64arr(n)
    3l: RETURN, fltarr(n)
    4l: RETURN, dblarr(n)
  endcase
end

function rdtree_rdkey, fname
  compile_opt idl2
  openr, 1, fname

  bidtag = 0l
  readu, 1, bidtag

  nkey = 0ll
  readu, 1, nkey

  key = rdtree_mkarray(nkey, bidtag)

  keyval = 0ll
  readu, 1, keyval

  readu, 1, key

  close, 1

  key[0] = keyval

  RETURN, key
end

function rdtree_rdtree, fname, rddump = rddump
  compile_opt idl2
  openr, 1, fname

  gidtag = 0l
  snaptag = 0l
  bidtag = 0l
  mertag = 0l

  readu, 1, gidtag
  readu, 1, snaptag
  readu, 1, bidtag
  readu, 1, mertag

  if keyword_set(rddump) then begin
    ntree = 0ll
    readu, 1, ntree
  endif

  lind = 0ll
  readu, 1, lind

  tree = ptrarr(lind + 1ll)

  for i = 0l, lind do begin
    nbranch = 0l
    nmerge = 0l
    ; fid 		= 0L
    fid = rdtree_mkarray(1, bidtag)
    tstat = 0l
    readu, 1, nbranch
    
    if nbranch le 0l then begin
      tree[i] = ptr_new({stat: -1l})
      continue
    endif

    readu, 1, nmerge
    readu, 1, fid
    readu, 1, tstat

    idtmp = rdtree_mkarray(nbranch, gidtag)
    snaptmp = rdtree_mkarray(nbranch, snaptag)

    mertmp = rdtree_mkarray(nbranch, mertag)

    readu, 1, idtmp
    readu, 1, snaptmp

    if keyword_set(rddump) then begin
      pidtmp = rdtree_mkarray(nbranch, gidtag)
      psnaptmp = rdtree_mkarray(nbranch, snaptag)
      readu, 1, pidtmp
      readu, 1, psnaptmp
    endif

    readu, 1, mertmp

    if nmerge ge 1l then begin
      midtmp = rdtree_mkarray(nmerge, gidtag)
      msnaptmp = rdtree_mkarray(nmerge, snaptag)
      mmertmp = rdtree_mkarray(nmerge, mertag)
      mbidtmp = rdtree_mkarray(nmerge, bidtag)

      readu, 1, midtmp
      readu, 1, msnaptmp
      readu, 1, mmertmp
      readu, 1, mbidtmp
    endif else begin
      midtmp = rdtree_mkarray(1, gidtag)
      msnaptmp = rdtree_mkarray(1, snaptag)
      mmertmp = rdtree_mkarray(1, mertag)
      mbidtmp = rdtree_mkarray(1, bidtag)
    endelse

    tmp = {br_len: nbranch, father_id: fid, n_mergebr: nmerge, $
      id: idtmp, snap: snaptmp, $ ; p_id:pidtmp, p_snap:psnaptmp,
      merit: mertmp, $
      m_id: midtmp, m_snap: msnaptmp, m_merit: mmertmp, m_bid: mbidtmp, $
      stat: 1l}
    tree[i] = ptr_new(tmp)
  endfor

  close, 1

  tree = tree[0l : lind]
  RETURN, tree
end

pro rdtree, rddump = rddump
  compile_opt idl2

  treename = './ctree_key.dat'
  keyname = './ctree_tree.dat'
  varname = './ctree.sav'

  tree_key = rdtree_rdkey(treename)
  tree_data = rdtree_rdtree(keyname, rddump = rddump)

  save, filename = varname, tree_key, tree_data

  stop
end
