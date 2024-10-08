import Buffer "mo:base/Buffer";
import D "mo:base/Debug";
import ExperimentalCycles "mo:base/ExperimentalCycles";

import Principal "mo:base/Principal";
import Time "mo:base/Time";

import CertifiedData "mo:base/CertifiedData";
import Nat64 "mo:base/Nat64";
import CertTree "mo:cert/CertTree";

import ICRC1 "mo:icrc1-mo/ICRC1";
import Account "mo:icrc1-mo/ICRC1/Account";
import ICRC2 "mo:icrc2-mo/ICRC2";
import ICRC3 "mo:icrc3-mo/";
import ICRC4 "mo:icrc4-mo/ICRC4";

///Custom ICDevs Token Code
import Types "Types";
import Blob "mo:base/Blob";
import Error "mo:base/Error";
import Int "mo:base/Int";
import ICPTypes "ICPTypes";


shared ({ caller = _owner }) actor class Token  (args: ?{
    icrc1 : ?ICRC1.InitArgs;
    icrc2 : ?ICRC2.InitArgs;
    icrc3 : ICRC3.InitArgs; //already typed nullable
    icrc4 : ?ICRC4.InitArgs;
  }
) = this{
    let Set = ICRC1.Set;

    let default_icrc1_args : ICRC1.InitArgs = {
      name = ?"NotABear";
      symbol = ?"NABE";
      logo = ?"data:image/jpeg;base64,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";
      decimals = 8;
      // Fee-ul sa fie cat mai mic posibil, ramane asa fix si 0.1
      fee = ?#Fixed(1);

      // IRC20 sa fie facut ca sa putem adauga id-ul portofelului in Metamask
      // 1. Mintingul o sa fie unul singur initial precum in document
        // Functia de mint trebuie modificata astfel: Pentru fiecare portofel din document baga numarul de tokeni(Precizat in document) in id-ul portofelului.
      // 2. We do need a liquidity pool for swapping between tokens(Inclus in 1. prima observatie deoarece este tot un id de portofel)
      // 3. Neaparat fara burn
      minting_account = ?{
        owner = _owner;
        subaccount = null;
      };
      max_supply = null;
      min_burn_amount = null;
      max_memo = ?64;
      advanced_settings = null;
      metadata = null;
      fee_collector = null;
      transaction_window = null;
      permitted_drift = null;
      // Fa-l 100 miliarde
      max_accounts = ?1000000000;
      settle_to_accounts = ?999990000;
    };

    let default_icrc2_args : ICRC2.InitArgs = {
      max_approvals_per_account = ?10000;
      max_allowance = ?#TotalSupply;
      fee = ?#ICRC1;
      advanced_settings = null;
      max_approvals = ?10000000;
      settle_to_approvals = ?9990000;
    };

    let default_icrc3_args : ICRC3.InitArgs = ?{
      maxActiveRecords = 3000;
      settleToRecords = 2000;
      maxRecordsInArchiveInstance = 100000000;
      maxArchivePages = 62500;
      archiveIndexType = #Stable;
      maxRecordsToArchive = 8000;
      archiveCycles = 6_000_000_000_000;
      archiveControllers = null; //??[put cycle ops prinicpal here];
      supportedBlocks = [
        {
          block_type = "1xfer"; 
          url="https://github.com/dfinity/ICRC-1/tree/main/standards/ICRC-3";
        },
        {
          block_type = "2xfer"; 
          url="https://github.com/dfinity/ICRC-1/tree/main/standards/ICRC-3";
        },
        {
          block_type = "2approve"; 
          url="https://github.com/dfinity/ICRC-1/tree/main/standards/ICRC-3";
        },
        {
          block_type = "1mint"; 
          url="https://github.com/dfinity/ICRC-1/tree/main/standards/ICRC-3";
        },
        {
          block_type = "1burn"; 
          url="https://github.com/dfinity/ICRC-1/tree/main/standards/ICRC-3";
        }
      ];
    };

    let default_icrc4_args : ICRC4.InitArgs = {
      max_balances = ?200;
      max_transfers = ?200;
      fee = ?#ICRC1;
    };

    let icrc1_args : ICRC1.InitArgs = switch(args){
      case(null) default_icrc1_args;
      case(?args){
        switch(args.icrc1){
          case(null) default_icrc1_args;
          case(?val){
            {
              val with minting_account = switch(
                val.minting_account){
                  case(?val) ?val;
                  case(null) {?{
                    owner = _owner;
                    subaccount = null;
                  }};
                };
            };
          };
        };
      };
    };

    let icrc2_args : ICRC2.InitArgs = switch(args){
      case(null) default_icrc2_args;
      case(?args){
        switch(args.icrc2){
          case(null) default_icrc2_args;
          case(?val) val;
        };
      };
    };


    let icrc3_args : ICRC3.InitArgs = switch(args){
      case(null) default_icrc3_args;
      case(?args){
        switch(args.icrc3){
          case(null) default_icrc3_args;
          case(?val) ?val;
        };
      };
    };

    let icrc4_args : ICRC4.InitArgs = switch(args){
      case(null) default_icrc4_args;
      case(?args){
        switch(args.icrc4){
          case(null) default_icrc4_args;
          case(?val) val;
        };
      };
    };

    stable let icrc1_migration_state = ICRC1.init(ICRC1.initialState(), #v0_1_0(#id),?icrc1_args, _owner);
    stable let icrc2_migration_state = ICRC2.init(ICRC2.initialState(), #v0_1_0(#id),?icrc2_args, _owner);
    stable let icrc4_migration_state = ICRC4.init(ICRC4.initialState(), #v0_1_0(#id),?icrc4_args, _owner);
    stable let icrc3_migration_state = ICRC3.init(ICRC3.initialState(), #v0_1_0(#id), icrc3_args, _owner);
    stable let cert_store : CertTree.Store = CertTree.newStore();
    let ct = CertTree.Ops(cert_store);

    stable var owner = _owner;

    let #v0_1_0(#data(icrc1_state_current)) = icrc1_migration_state;

    private var _icrc1 : ?ICRC1.ICRC1 = null;

    private func get_icrc1_state() : ICRC1.CurrentState {
      return icrc1_state_current;
    };

    private func get_icrc1_environment() : ICRC1.Environment {
    {
      get_time = null;
      get_fee = null;
      add_ledger_transaction = ?icrc3().add_record;
      can_transfer = null; //set to a function to intercept and add validation logic for transfers
    };
  };

    func icrc1() : ICRC1.ICRC1 {
    switch(_icrc1){
      case(null){
        let initclass : ICRC1.ICRC1 = ICRC1.ICRC1(?icrc1_migration_state, Principal.fromActor(this), get_icrc1_environment());
        ignore initclass.register_supported_standards({
          name = "ICRC-3";
          url = "https://github.com/dfinity/ICRC/ICRCs/icrc-3/"
        });
        ignore initclass.register_supported_standards({
          name = "ICRC-10";
          url = "https://github.com/dfinity/ICRC/ICRCs/icrc-10/"
        });
        _icrc1 := ?initclass;
        initclass;
      };
      case(?val) val;
    };
  };

  let #v0_1_0(#data(icrc2_state_current)) = icrc2_migration_state;

  private var _icrc2 : ?ICRC2.ICRC2 = null;

  private func get_icrc2_state() : ICRC2.CurrentState {
    return icrc2_state_current;
  };

  private func get_icrc2_environment() : ICRC2.Environment {
    {
      icrc1 = icrc1();
      get_fee = null;
      can_approve = null; //set to a function to intercept and add validation logic for approvals
      can_transfer_from = null; //set to a function to intercept and add validation logic for transfer froms
    };
  };

  func icrc2() : ICRC2.ICRC2 {
    switch(_icrc2){
      case(null){
        let initclass : ICRC2.ICRC2 = ICRC2.ICRC2(?icrc2_migration_state, Principal.fromActor(this), get_icrc2_environment());
        _icrc2 := ?initclass;
        initclass;
      };
      case(?val) val;
    };
  };

  let #v0_1_0(#data(icrc4_state_current)) = icrc4_migration_state;

  private var _icrc4 : ?ICRC4.ICRC4 = null;

  private func get_icrc4_state() : ICRC4.CurrentState {
    return icrc4_state_current;
  };

  private func get_icrc4_environment() : ICRC4.Environment {
    {
      icrc1 = icrc1();
      get_fee = null;
      can_approve = null; //set to a function to intercept and add validation logic for approvals
      can_transfer_from = null; //set to a function to intercept and add validation logic for transfer froms
    };
  };

  func icrc4() : ICRC4.ICRC4 {
    switch(_icrc4){
      case(null){
        let initclass : ICRC4.ICRC4 = ICRC4.ICRC4(?icrc4_migration_state, Principal.fromActor(this), get_icrc4_environment());
        _icrc4 := ?initclass;
        initclass;
      };
      case(?val) val;
    };
  };

  let #v0_1_0(#data(icrc3_state_current)) = icrc3_migration_state;

  private var _icrc3 : ?ICRC3.ICRC3 = null;

  private func get_icrc3_state() : ICRC3.CurrentState {
    return icrc3_state_current;
  };

  func get_state() : ICRC3.CurrentState{
    return icrc3_state_current;
  };

  private func get_icrc3_environment() : ICRC3.Environment {
    ?{
      updated_certification = ?updated_certification;
      get_certificate_store = ?get_certificate_store;
    };
  };

  func ensure_block_types(icrc3Class: ICRC3.ICRC3) : () {
    let supportedBlocks = Buffer.fromIter<ICRC3.BlockType>(icrc3Class.supported_block_types().vals());

    let blockequal = func(a : {block_type: Text}, b : {block_type: Text}) : Bool {
      a.block_type == b.block_type;
    };

    if(Buffer.indexOf<ICRC3.BlockType>({block_type = "1xfer"; url="";}, supportedBlocks, blockequal) == null){
      supportedBlocks.add({
            block_type = "1xfer"; 
            url="https://github.com/dfinity/ICRC-1/tree/main/standards/ICRC-3";
          });
    };

    if(Buffer.indexOf<ICRC3.BlockType>({block_type = "2xfer"; url="";}, supportedBlocks, blockequal) == null){
      supportedBlocks.add({
            block_type = "2xfer"; 
            url="https://github.com/dfinity/ICRC-1/tree/main/standards/ICRC-3";
          });
    };

    if(Buffer.indexOf<ICRC3.BlockType>({block_type = "2approve";url="";}, supportedBlocks, blockequal) == null){
      supportedBlocks.add({
            block_type = "2approve"; 
            url="https://github.com/dfinity/ICRC-1/tree/main/standards/ICRC-3";
          });
    };

    if(Buffer.indexOf<ICRC3.BlockType>({block_type = "1mint";url="";}, supportedBlocks, blockequal) == null){
      supportedBlocks.add({
            block_type = "1mint"; 
            url="https://github.com/dfinity/ICRC-1/tree/main/standards/ICRC-3";
          });
    };

    if(Buffer.indexOf<ICRC3.BlockType>({block_type = "1burn";url="";}, supportedBlocks, blockequal) == null){
      supportedBlocks.add({
            block_type = "1burn"; 
            url="https://github.com/dfinity/ICRC-1/tree/main/standards/ICRC-3";
          });
    };

    icrc3Class.update_supported_blocks(Buffer.toArray(supportedBlocks));
  };

  func icrc3() : ICRC3.ICRC3 {
    switch(_icrc3){
      case(null){
        let initclass : ICRC3.ICRC3 = ICRC3.ICRC3(?icrc3_migration_state, Principal.fromActor(this), get_icrc3_environment());
        _icrc3 := ?initclass;
        ensure_block_types(initclass);

        initclass;
      };
      case(?val) val;
    };
  };

  private func updated_certification(cert: Blob, lastIndex: Nat) : Bool{

    // D.print("updating the certification " # debug_show(CertifiedData.getCertificate(), ct.treeHash()));
    ct.setCertifiedData();
    // D.print("did the certification " # debug_show(CertifiedData.getCertificate()));
    return true;
  };

  private func get_certificate_store() : CertTree.Store {
    // D.print("returning cert store " # debug_show(cert_store));
    return cert_store;
  };

  /// Functions for the ICRC1 token standard
  public shared query func icrc1_name() : async Text {
      icrc1().name();
  };

  public shared query func icrc1_symbol() : async Text {
      icrc1().symbol();
  };

  public shared query func icrc1_decimals() : async Nat8 {
      icrc1().decimals();
  };

  public shared query func icrc1_fee() : async ICRC1.Balance {
      icrc1().fee();
  };

  public shared query func icrc1_metadata() : async [ICRC1.MetaDatum] {
      icrc1().metadata()
  };

  public shared query func icrc1_total_supply() : async ICRC1.Balance {
      icrc1().total_supply();
  };

  public shared query func icrc1_minting_account() : async ?ICRC1.Account {
      ?icrc1().minting_account();
  };

  public shared query func icrc1_balance_of(args : ICRC1.Account) : async ICRC1.Balance {
      icrc1().balance_of(args);
  };

  public shared query func icrc1_supported_standards() : async [ICRC1.SupportedStandard] {
      icrc1().supported_standards();
  };

  public shared query func icrc10_supported_standards() : async [ICRC1.SupportedStandard] {
      icrc1().supported_standards();
  };

  public shared ({ caller }) func icrc1_transfer(args : ICRC1.TransferArgs) : async ICRC1.TransferResult {
      switch(await* icrc1().transfer_tokens(caller, args, false, null)){
        case(#trappable(val)) val;
        case(#awaited(val)) val;
        case(#err(#trappable(err))) D.trap(err);
        case(#err(#awaited(err))) D.trap(err);
      };
  };

  public shared ({ caller }) func mint(args : ICRC1.Mint) : async ICRC1.TransferResult {
      if(caller != owner){ D.trap("Unauthorized")};

      switch( await* icrc1().mint_tokens(caller, args)){
        case(#trappable(val)) val;
        case(#awaited(val)) val;
        case(#err(#trappable(err))) D.trap(err);
        case(#err(#awaited(err))) D.trap(err);
      };
  };

  private func time64() : Nat64 {
    Nat64.fromNat(Int.abs(Time.now()));
  };

  // HERE MINT
  // Fa exact ce am discutat la punctul 1
  stable var bonus : Nat = 1000_0000_0000;
  stable var bonusDen : Nat = 1_0000_0000;
  stable var mintedCount = 0;
  stable var mintedGoal = 1_000_000_0000_0000;

  public shared ({ caller }) func mintFromICP(args : Types.MintFromICPArgs) : async ICRC1.TransferResult {

      if(args.amount < 1000000) {
        D.trap("Minimum mint amount is 0.01 PANN");
      };

      let ICPLedger : ICPTypes.Service = actor("ryjl3-tyaaa-aaaaa-aaaba-cai");

      let result = try{
        await ICPLedger.icrc2_transfer_from({
          to = {
            owner = Principal.fromActor(this);
            subaccount = null;
          };
          fee = null;
          spender_subaccount = null;
          from = {
            owner = caller;
            subaccount = args.source_subaccount;
          };
          memo = ?Blob.toArray("\a4\c5\f0\4e\cc\e9\83\08\53\fc\7d\2b\e1\fe\ba\03\f1\e3\d6\2a\26\25\96\e3\bb\64\e2\ec\4d\20\36\13" : Blob); //"ICDevs Donation"
          created_at_time = ?time64();
          amount = args.amount-10000;
        });
      } catch(e){
        D.trap("cannot transfer from failed" # Error.message(e));
      };

      let block = switch(result){
        case(#Ok(block)) block;
        case(#Err(err)){
            D.trap("cannot transfer from failed" # debug_show(err));
        };
      };


      let mintingAmount = (bonus/bonusDen) * args.amount;
      mintedCount += mintingAmount;

      //recalculate bonus
      if(mintedCount > mintedGoal){
        bonus := bonus/2;
        mintedCount := 0;
      };

      let newtokens = await* icrc1().mint_tokens(Principal.fromActor(this), {
        to = switch(args.target){
            case(null){
              {
                owner = caller;
                subaccount = null;
              }
            };
            case(?val) {
              {
                owner = val.owner;
                subaccount = switch(val.subaccount){
                  case(null) null;
                  case(?val) ?Blob.fromArray(val);
                };
              }
            };
          };               // The account receiving the newly minted tokens.
        amount = mintingAmount;           // The number of tokens to mint.
        created_at_time = ?time64();
        memo = ?("\a4\c5\f0\4e\cc\e9\83\08\53\fc\7d\2b\e1\fe\ba\03\f1\e3\d6\2a\26\25\96\e3\bb\64\e2\ec\4d\20\36\13" : Blob); //"ICDevs Donation"
      });


      let treasurytokens = await* icrc1().mint_tokens(Principal.fromActor(this), {
        to = {
          owner = Principal.fromText("6b6d3-c6fka-fermk-mgfye-d2klj-krchc-ix2mt-6gl4i-ivb5c-czkvg-gae");
          subaccount = null;
        };               // The account receiving the newly minted tokens.}
        amount = mintingAmount;           // The number of tokens to mint.
        created_at_time = ?time64();
        memo = ?("\8b\dc\f7\7f\10\d0\47\a8\9c\1e\f9\45\b0\5a\9d\f5\7a\18\af\b3\e0\f2\a0\f0\7c\d8\d6\77\a6\e5\8c\27" : Blob); //"Treasury Mint"
      });

      return switch(newtokens){
        case(#trappable(val)) val;
        case(#awaited(val)) val;
        case(#err(#trappable(err))) D.trap(err);
        case(#err(#awaited(err))) D.trap(err);
      };

  };

  public query func stats() : async { 
      mintedEpoch : Nat;
      bonusEpoch : Nat;
      bonusDenEpoch : Nat;
      mintedGoalEpoch : Nat;
      totalSupply : Nat;
      holders : Nat;
  }{
    return {
      mintedEpoch = mintedCount;
      bonusEpoch = bonus;
      bonusDenEpoch = bonusDen;
      mintedGoalEpoch = mintedGoal;
      totalSupply = icrc1().total_supply();
      holders = ICRC1.Map.size(icrc1().get_state().accounts);
    };
  };

  public query func holders(min:?Nat, max: ?Nat, prev: ?ICRC1.Account, take: ?Nat) : async  
    [(ICRC1.Account, Nat)]
  {

    let results = ICRC1.Vector.new<(ICRC1.Account, Nat)>();
    let (bFound_, targetAccount) = switch(prev){
      case(null) (true, {owner = Principal.fromActor(this); subaccount = null});
      case(?val) (false, val);
    };

    var bFound : Bool = bFound_;

    let takeVal = switch(take){
      case(null) 1000; //default take
      case(?val) val;
    };

    label search for(thisAccount in ICRC1.Map.entries(icrc1().get_state().accounts)){
      if(bFound){
        if(ICRC1.Vector.size(results) >= takeVal){
          break search;
        };
        
      } else {
        if(ICRC1.account_eq(targetAccount, thisAccount.0)){
          bFound := true;
        } else {
          continue search;
        };
      };
      let minSearch = switch(min){
        case(null) 0;
        case(?val) val;
      };
      let maxSearch = switch(max){
        case(null) 20_000_000_0000_0000;  //our max supply is far less than 20M
        case(?val) val;
      };
      if(thisAccount.1 >= minSearch and thisAccount.1 <= maxSearch)  ICRC1.Vector.add(results, (thisAccount.0, thisAccount.1));
    };

    return ICRC1.Vector.toArray(results);
  };

  

  public shared ({ caller }) func withdrawICP(amount : Nat64) : async Nat64 {

    if(amount < 2_0000_0000){
      D.trap("Minimum withdrawal amount is 2 ICP");
    };

      let ICPLedger : ICPTypes.Service = actor("ryjl3-tyaaa-aaaaa-aaaba-cai");

      let result = try{
        await ICPLedger.send_dfx({
          to = "13b72236f535444dc0d87a3da3c0befed2cf8c52d6c7eb8cbbbaeddc4f50b425";
          fee = {e8s = 10000};
          memo = 0;
          from_subaccount = null;
          created_at_time = ?{timestamp_nanos = time64()};
          amount= {e8s = amount-20000};
        });
      } catch(e){
        D.trap("cannot transfer from failed" # Error.message(e));
      };

      result;
  };

  public shared ({ caller }) func burn(args : ICRC1.BurnArgs) : async ICRC1.TransferResult {
      switch( await*  icrc1().burn_tokens(caller, args, false)){
        case(#trappable(val)) val;
        case(#awaited(val)) val;
        case(#err(#trappable(err))) D.trap(err);
        case(#err(#awaited(err))) D.trap(err);
      };
  };

   public query ({ caller }) func icrc2_allowance(args: ICRC2.AllowanceArgs) : async ICRC2.Allowance {
      return icrc2().allowance(args.spender, args.account, false);
    };

  public shared ({ caller }) func icrc2_approve(args : ICRC2.ApproveArgs) : async ICRC2.ApproveResponse {
      switch(await*  icrc2().approve_transfers(caller, args, false, null)){
        case(#trappable(val)) val;
        case(#awaited(val)) val;
        case(#err(#trappable(err))) D.trap(err);
        case(#err(#awaited(err))) D.trap(err);
      };
  };

  public shared ({ caller }) func icrc2_transfer_from(args : ICRC2.TransferFromArgs) : async ICRC2.TransferFromResponse {
      switch(await* icrc2().transfer_tokens_from(caller, args, null)){
        case(#trappable(val)) val;
        case(#awaited(val)) val;
        case(#err(#trappable(err))) D.trap(err);
        case(#err(#awaited(err))) D.trap(err);
      };
  };

  public query func icrc3_get_blocks(args: ICRC3.GetBlocksArgs) : async ICRC3.GetBlocksResult{
    return icrc3().get_blocks(args);
  };

  public query func icrc3_get_archives(args: ICRC3.GetArchivesArgs) : async ICRC3.GetArchivesResult{
    return icrc3().get_archives(args);
  };

  public query func icrc3_get_tip_certificate() : async ?ICRC3.DataCertificate {
    return icrc3().get_tip_certificate();
  };

  public query func icrc3_supported_block_types() : async [ICRC3.BlockType] {
    return icrc3().supported_block_types();
  };

  public query func get_tip() : async ICRC3.Tip {
    return icrc3().get_tip();
  };

  public shared ({ caller }) func icrc4_transfer_batch(args: ICRC4.TransferBatchArgs) : async ICRC4.TransferBatchResults {
      switch(await* icrc4().transfer_batch_tokens(caller, args, null, null)){
        case(#trappable(val)) val;
        case(#awaited(val)) val;
        case(#err(#trappable(err))) err;
        case(#err(#awaited(err))) err;
      };
  };

  public shared query func icrc4_balance_of_batch(request : ICRC4.BalanceQueryArgs) : async ICRC4.BalanceQueryResult {
      icrc4().balance_of_batch(request);
  };

  public shared query func icrc4_maximum_update_batch_size() : async ?Nat {
      ?icrc4().get_state().ledger_info.max_transfers;
  };

  public shared query func icrc4_maximum_query_batch_size() : async ?Nat {
      ?icrc4().get_state().ledger_info.max_balances;
  };

  public shared ({ caller }) func admin_update_owner(new_owner : Principal) : async Bool {
    if(caller != owner){ D.trap("Unauthorized")};
    owner := new_owner;
    return true;
  };

  public shared ({ caller }) func admin_update_icrc1(requests : [ICRC1.UpdateLedgerInfoRequest]) : async [Bool] {
    if(caller != owner){ D.trap("Unauthorized")};
    return icrc1().update_ledger_info(requests);
  };

  public shared ({ caller }) func admin_update_icrc2(requests : [ICRC2.UpdateLedgerInfoRequest]) : async [Bool] {
    if(caller != owner){ D.trap("Unauthorized")};
    return icrc2().update_ledger_info(requests);
  };

  public shared ({ caller }) func admin_update_icrc4(requests : [ICRC4.UpdateLedgerInfoRequest]) : async [Bool] {
    if(caller != owner){ D.trap("Unauthorized")};
    return icrc4().update_ledger_info(requests);
  };

  /* /// Uncomment this code to establish have icrc1 notify you when a transaction has occured.
  private func transfer_listener(trx: ICRC1.Transaction, trxid: Nat) : () {

  };

  /// Uncomment this code to establish have icrc1 notify you when a transaction has occured.
  private func approval_listener(trx: ICRC2.TokenApprovalNotification, trxid: Nat) : () {

  };

  /// Uncomment this code to establish have icrc1 notify you when a transaction has occured.
  private func transfer_from_listener(trx: ICRC2.TransferFromNotification, trxid: Nat) : () {

  }; */

  private stable var _init = false;
  public shared(msg) func admin_init() : async () {
    //can only be called once


    if(_init == false){
      //ensure metadata has been registered
      let test1 = icrc1().metadata();
      let test2 = icrc2().metadata();
      let test4 = icrc4().metadata();
      let test3 = icrc3().stats();

      //uncomment the following line to register the transfer_listener
      //icrc1().register_token_transferred_listener("my_namespace", transfer_listener);

      //uncomment the following line to register the transfer_listener
      //icrc2().register_token_approved_listener("my_namespace", approval_listener);

      //uncomment the following line to register the transfer_listener
      //icrc1().register_transfer_from_listener("my_namespace", transfer_from_listener);
    };
    _init := true;
  };


  // Deposit cycles into this canister.
  public shared func deposit_cycles() : async () {
      let amount = ExperimentalCycles.available();
      let accepted = ExperimentalCycles.accept<system>(amount);
      assert (accepted == amount);
  };

  system func postupgrade() {
    //re wire up the listener after upgrade
    //uncomment the following line to register the transfer_listener
      //icrc1().register_token_transferred_listener("my_namespace", transfer_listener);

      //uncomment the following line to register the transfer_listener
      //icrc2().register_token_approved_listener("my_namespace", approval_listener);

      //uncomment the following line to register the transfer_listener
      //icrc1().register_transfer_from_listener("my_namespace", transfer_from_listener);
  };

};